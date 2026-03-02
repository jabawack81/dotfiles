# New Project CLAUDE.md Template

Projects should have an `AGENTS.md` file with the project instructions, symlinked as `CLAUDE.md` (so the source of truth has a descriptive name while Claude still finds it automatically).

When creating or initializing a project's Claude config, follow this structure:

## Required Sections

### 1. Project Description (1 line)
Single sentence describing what the project is.

### 2. Build Commands (minimal)
Only the essential commands needed for development:
- Test command
- Lint command
- Build/run command (if applicable)

### 3. Critical Rules (include these standard rules)
- **Pin dependencies** to exact versions (latest patch unless older version needed)
- **Keep docs updated** - update /docs/ with every code/feature change
- **Keep Makefile updated** - all project tasks should be in the Makefile with an interactive menu
- Add 2-3 project-specific rules maximum

### 4. Makefile with Interactive Menu
Every project should have a Makefile that:
- Contains all common tasks (test, lint, build, install, etc.)
- Has `make` (default) show an interactive numbered menu
- Has `make help` show all commands with descriptions
- Has `make list` for quick reference
- Is kept updated as the project evolves

Menu structure example:
```makefile
.DEFAULT_GOAL := menu

menu:
	@echo "╔══════════════════════════════════════════════════════╗"
	@echo "║              Project Name - Command Menu             ║"
	@echo "╚══════════════════════════════════════════════════════╝"
	@echo ""
	@echo "  === Development ==="
	@echo "  1) Start server"
	@echo "  2) Run console"
	@echo ""
	@echo "  === Testing ==="
	@echo "  3) Run all tests"
	@echo "  4) Run linter"
	@echo ""
	@read -p "Enter choice: " choice; \
	case $$choice in \
		1) $(MAKE) server ;; \
		2) $(MAKE) console ;; \
		3) $(MAKE) test ;; \
		4) $(MAKE) lint ;; \
		*) echo "Invalid choice" ;; \
	esac

help:
	@echo "Available commands:"
	@echo "  make server  - Start development server"
	@echo "  make test    - Run all tests"
	@echo "  make lint    - Run linter"
```

### 5. Links to Detailed Docs
Use a markdown table linking to docs/ files for detailed information.
Only create links to docs that actually exist.

## Example Format

```markdown
# Project Name

One-sentence project description.

## Build Commands

```bash
make test    # or npm test, cargo test, etc.
make lint    # or npm run lint, etc.
```

## Critical Rules

- Pin dependencies and languages to exact latest versions (e.g., `"package": "1.2.3"`) and use rbenv and nodenv for version management
- Keep docs updated with every code change
- Keep Makefile updated - add new tasks as project evolves
- [1-3 project-specific rules]

## Detailed Guides

| Topic | Guide |
|-------|-------|
| Architecture | [docs/architecture.md](docs/architecture.md) |
| Testing | [docs/testing.md](docs/testing.md) |
```

## What NOT to Include
- Information Claude already knows (language conventions, etc.)
- Verbose explanations (put those in linked docs)
- More than 5 critical rules
- Specific test counts or coverage numbers (they go stale)
