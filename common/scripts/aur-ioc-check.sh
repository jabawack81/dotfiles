#!/usr/bin/env bash
# Scan for indicators of the "Atomic Arch" AUR supply-chain compromise.
#
# In June 2026 attackers adopted ~1500 orphaned AUR packages and patched their
# PKGBUILDs to pull the malicious npm package `atomic-lockfile`, which fetched a
# Rust infostealer (and, with root, an eBPF rootkit to hide itself).
#
# The circulating checker scripts match a hardcoded list of package names. Those
# lists are snapshots: the one dated 2026-06-11 held 446 names, its own cited
# source yielded 681, and the campaign touched roughly 1500. A name list is
# always behind, so this script looks for the *behaviour* instead — the npm/bun
# invocations in build files, the payload on disk, and package activity during
# the attack window. Those don't go stale.
#
# No sudo, no network, read-only. Exit 0 clean, 1 findings, 2 usage error.

set -uo pipefail

# Attack window. Wave 1 was disclosed 2026-06-11, wave 2 on 2026-06-12; the
# window is padded either side because adoption predates disclosure.
WINDOW_START="${AUR_IOC_WINDOW_START:-2026-06-01}"
WINDOW_END="${AUR_IOC_WINDOW_END:-2026-06-20}"

PAYLOAD_RE='atomic-lockfile'
# `bun add` / `bunx` in a PKGBUILD is the campaign's signature. Plain `npm i`
# appears in legitimate packages too, so it is reported as review-worthy rather
# than as a hit.
BUILD_HOT_RE='atomic-lockfile|bun[[:space:]]+add|bunx'
BUILD_WARM_RE='npm[[:space:]]+(i|install|ci)|yarn[[:space:]]+add|pnpm[[:space:]]+(add|install)'

BOLD=$'\033[1m'; RED=$'\033[31m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; DIM=$'\033[2m'; RESET=$'\033[0m'
[[ -t 1 ]] || { BOLD=""; RED=""; GREEN=""; YELLOW=""; DIM=""; RESET=""; }

findings=0
warnings=0

hit()  { printf "  %s%sHIT%s  %s\n" "$BOLD" "$RED" "$RESET" "$1"; findings=$((findings + 1)); }
warn() { printf "  %s%s? %s  %s\n" "$BOLD" "$YELLOW" "$RESET" "$1"; warnings=$((warnings + 1)); }
ok()   { printf "  %s%sok%s   %s\n" "$BOLD" "$GREEN" "$RESET" "$1"; }
note() { printf "       %s%s%s\n" "$DIM" "$1" "$RESET"; }
head_() { printf "\n%s%s%s\n" "$BOLD" "$1" "$RESET"; }

usage() {
    cat <<EOF
Usage: $(basename "$0") [--list FILE]

  --list FILE   Additionally match installed AUR packages against a newline-
                separated list of known-bad names (lines starting with # and
                blank lines are ignored). Optional — the checks below do not
                depend on it.

Environment:
  AUR_IOC_WINDOW_START / AUR_IOC_WINDOW_END   override the date window
                                              (default $WINDOW_START .. $WINDOW_END)
EOF
}

list_file=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --list) list_file="${2:-}"; [[ -n "$list_file" ]] || { usage >&2; exit 2; }; shift 2 ;;
        -h|--help) usage; exit 0 ;;
        *) printf "unknown argument: %s\n\n" "$1" >&2; usage >&2; exit 2 ;;
    esac
done

command -v pacman >/dev/null || { echo "pacman not found — this is an Arch-only check." >&2; exit 2; }

printf "%sAUR supply-chain indicator scan%s\n" "$BOLD" "$RESET"
note "window $WINDOW_START .. $WINDOW_END"

###############################################################################
head_ "1. Build files invoking a JS package manager"
###############################################################################
# Cached PKGBUILDs from AUR helpers, plus .install hooks (post_install runs as
# root, which is how the eBPF stage got its privileges).
build_files=()
while IFS= read -r f; do build_files+=("$f"); done < <(
    find ~/.cache/yay ~/.cache/paru ~/.cache/pikaur ~/.cache/aurutils \
         -maxdepth 3 \( -name PKGBUILD -o -name '*.install' \) 2>/dev/null
)

if [[ ${#build_files[@]} -eq 0 ]]; then
    ok "no cached build files found (nothing to scan)"
else
    hot=$(grep -lEi "$BUILD_HOT_RE" "${build_files[@]}" 2>/dev/null)
    warm=$(grep -lEi "$BUILD_WARM_RE" "${build_files[@]}" 2>/dev/null)

    if [[ -n "$hot" ]]; then
        while IFS= read -r f; do hit "campaign signature in ${f/#$HOME/\~}"; done <<< "$hot"
    else
        ok "${#build_files[@]} build files scanned, no campaign signature"
    fi

    if [[ -n "$warm" ]]; then
        while IFS= read -r f; do warn "invokes a JS package manager: ${f/#$HOME/\~}"; done <<< "$warm"
        note "common in legitimate packages — worth an eyeball, not proof of anything"
    fi
fi

###############################################################################
head_ "2. Payload on disk"
###############################################################################
payload=$(find "$HOME" /opt /usr/lib/node_modules /usr/local/lib/node_modules \
               -maxdepth 7 -name "*${PAYLOAD_RE}*" 2>/dev/null)
if [[ -n "$payload" ]]; then
    while IFS= read -r f; do hit "$f"; done <<< "$payload"
else
    ok "no ${PAYLOAD_RE} artefacts found"
fi

cache_hits=$(grep -rlI "$PAYLOAD_RE" ~/.bun ~/.npm ~/.cache/yay ~/.cache/paru 2>/dev/null)
if [[ -n "$cache_hits" ]]; then
    while IFS= read -r f; do hit "referenced in ${f/#$HOME/\~}"; done <<< "$cache_hits"
else
    ok "no ${PAYLOAD_RE} references in bun/npm/helper caches"
fi

###############################################################################
head_ "3. Package activity during the attack window"
###############################################################################
# The strongest single signal: if nothing was installed while the campaign was
# live, no compromised PKGBUILD ever ran.
if [[ -r /var/log/pacman.log ]]; then
    window=$(awk -v s="[$WINDOW_START" -v e="[$WINDOW_END" \
        '$1 >= s && $1 <= e"T99"' /var/log/pacman.log 2>/dev/null \
        | grep -E "\[ALPM\] (installed|upgraded)" || true)
    count=$(printf '%s' "$window" | grep -c . || true)
    if [[ "$count" -eq 0 ]]; then
        ok "no installs or upgrades in the window — no build script ran"
    else
        warn "$count package operations in the window"
        note "cross-check the AUR ones below against a known-bad list"
        printf '%s\n' "$window" | sed -E 's/.*\[ALPM\] (installed|upgraded) ([^ ]+).*/       \2/' | sort -u | head -30
    fi
else
    warn "/var/log/pacman.log unreadable — skipped"
fi

###############################################################################
head_ "4. Foreign (AUR) packages installed"
###############################################################################
mapfile -t foreign < <(pacman -Qmq 2>/dev/null | LC_ALL=C sort)
ok "${#foreign[@]} AUR packages installed"

if [[ -n "$list_file" ]]; then
    if [[ -r "$list_file" ]]; then
        mapfile -t known < <(grep -vE '^\s*(#|$)' "$list_file" | tr -d '"' | tr -d "'" | awk '{$1=$1};1' | LC_ALL=C sort -u)
        overlap=$(LC_ALL=C comm -12 \
            <(printf '%s\n' "${foreign[@]}") \
            <(printf '%s\n' "${known[@]}"))
        if [[ -n "$overlap" ]]; then
            while IFS= read -r p; do hit "installed and on the supplied list: $p"; done <<< "$overlap"
        else
            ok "none of the ${#known[@]} listed names are installed"
        fi
    else
        warn "list file not readable: $list_file"
    fi
else
    note "no --list given; name matching skipped (see the header for why)"
fi

###############################################################################
head_ "Result"
###############################################################################
if [[ $findings -gt 0 ]]; then
    printf "  %s%s%d indicator(s) found — investigate before trusting this machine.%s\n" "$BOLD" "$RED" "$findings" "$RESET"
    printf "  %sRotate any credentials this user can reach; the payload is an infostealer.%s\n" "$DIM" "$RESET"
    exit 1
fi

printf "  %s%sNo indicators found.%s" "$BOLD" "$GREEN" "$RESET"
[[ $warnings -gt 0 ]] && printf " %s(%d item(s) flagged for review)%s" "$DIM" "$warnings" "$RESET"
printf "\n"
note "Absence of evidence only: this checks known indicators, not arbitrary tampering."
exit 0
