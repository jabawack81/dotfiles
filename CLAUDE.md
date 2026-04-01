# Dotfiles Project Rules

## Private Config Submodule — CONFIDENTIALITY

- The `private-config` submodule contains work-related configuration. NEVER leak company names, project names, or internal tool names in commit messages, branch names, or any tracked file outside of `private-config/`.
- When committing a `private-config` submodule reference update, the commit message MUST be exactly: `chore: update private-config submodule reference` — nothing more, no details about what changed inside.
- If you notice any leak in existing commit messages, flag it immediately and offer to rewrite history.
