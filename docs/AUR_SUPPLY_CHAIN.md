# AUR Supply-Chain Checks

```bash
make aur-check                      # indicator scan
make aur-check LIST=known-bad.txt   # plus name matching against a list
```

Script: `common/scripts/aur-ioc-check.sh` (also on PATH as `~/.config/scripts/aur-ioc-check.sh`).
Read-only, no sudo, no network. Exit `0` clean, `1` indicators found, `2` usage error.

## The incident it was written for

In June 2026 attackers adopted roughly **1,500 orphaned AUR packages** and patched their
`PKGBUILD` files to install the malicious npm package `atomic-lockfile`. That pulled a
Rust infostealer targeting developer secrets; where it ran as root, it also loaded an
eBPF rootkit to hide itself. Wave 1 was disclosed 2026-06-11, wave 2 on 2026-06-12 using
expanded Bun-based install paths.

## Why not just match package names

The checker scripts circulating after disclosure carry a hardcoded list. Those lists are
snapshots, and they were incomplete on the day they were written:

| Source                                       | Names |
|----------------------------------------------|-------|
| Community script dated 2026-06-11             |   446 |
| `gr.ht/aur_pkg_list.txt`, the source it cites |   681 |
| Reported scale of the campaign                | ~1500 |

The cited source is not a curated list either — it is a raw
`git log --all -S 'bun add'` dump. Of its 751 commit lines only 681 carry a
`refs/remotes/origin/<pkg>` decoration, so **70 commits have no recoverable package
name at all**. The source is lossy by construction, and every such list ages badly.

So the script matches *behaviour*, which does not go stale. Name matching is available
via `--list` when you have a list worth checking, but nothing else depends on it.

## What it checks

| # | Check                                    | Why it matters                                                        |
|---|------------------------------------------|-----------------------------------------------------------------------|
| 1 | `bun add` / `bunx` / payload name in cached `PKGBUILD` and `.install` files | The campaign's signature. `.install` hooks run as root — that is how the eBPF stage got privileges. |
| 2 | `atomic-lockfile` on disk and in bun/npm/helper caches | The payload itself.                                                   |
| 3 | Package installs and upgrades during the attack window | The strongest single signal: if nothing was installed while the campaign was live, no compromised build script ever ran. |
| 4 | Installed AUR packages, optionally vs `--list` | Context, and name matching when you have a list.                      |

Check 1 also reports plain `npm install` / `yarn add` / `pnpm add` separately, as
review-worthy rather than as a hit — plenty of legitimate packages build that way.
`balena-etcher` is a standing example on this machine: it runs `npm install` in
`build()` to compile an Electron app, which is expected and fine.

The window defaults to `2026-06-01 .. 2026-06-20`, padded either side of disclosure
because adoption predates it. Override with `AUR_IOC_WINDOW_START` and
`AUR_IOC_WINDOW_END` to scope a different incident.

## Limits

Absence of evidence only. It looks for the indicators of *this* campaign, not for
arbitrary tampering. A clean result means these specific markers are absent, not that
every AUR package on the machine is trustworthy.

If check 1 or 2 ever fires, treat the machine as compromised: the payload is an
infostealer, so rotate anything the affected user could reach — SSH keys, cloud
credentials, browser sessions, password-manager unlocks.

## Related

Rebuilding an AUR package pulls a fresh `PKGBUILD` from upstream, so a build that was
clean last month is not necessarily clean today. `quickshell-git` gets rebuilt on every
Qt6 bump (see [ANSIBLE.md](ANSIBLE.md#bar-reverted-to-waybar-when-it-should-be-quickshell)),
which makes it a recurring opportunity to re-run this check.

## Sources

- [Phoronix — AUR sees more than 400 packages compromised](https://www.phoronix.com/news/Arch-Linux-AUR-400-Compromised)
- [Rescana — Atomic Arch supply chain attack, ~1500 packages](https://www.rescana.com/post/atomic-arch-supply-chain-attack-compromises-1-500-arch-user-repository-packages-credential-stealing-malware-targets-arch)
- [StepSecurity — What the Atomic Arch campaign means](https://www.stepsecurity.io/blog/400-aur-packages-hijacked-atomic-arch-campaign)
- [arch-general mailing list thread](https://lists.archlinux.org/archives/list/aur-general@lists.archlinux.org/thread/FGXPCB3ZVCJIV7FX323SBAX2JHYB7ZS4/)
