# agents-config

Shared AI agent rules (`AGENTS.md`, `rules/`) and custom skills (`skills/`) used across:
- **[`mac.dotfiles`](https://github.com/michalgr/mac.dotfiles)** (macOS host environment, managed via GNU Stow and Git submodule)
- **[`agent-jail`](https://github.com/michalgr/agent-jail)** (containerized Nix environment, managed via Nix Flakes and Home Manager)

## Structure

```text
agents-config/
├── .stow-local-ignore             # Excludes repo metadata when stowed
├── README.md
├── AGENTS.md                      # Global agent rules entry point (Table of Contents)
├── rules/                         # Modular domain-specific rule files
│   ├── git-commit-policy.md       # Interactive Git commit approval policy (local harnesses)
│   ├── code-structure.md          # Philosophy, Theorems & Lemmas, types, module size limits
│   ├── testing.md                 # First-class test code, strategy, invariants, shared test infra
│   └── documentation.md           # In-code commentary, Module Outline, and docs/*.md rules
└── skills/                        # Harness-agnostic agent skills
    └── jules/                     # Workflow for delegating tasks to Google's Jules agent
        ├── SKILL.md
        └── references/
            └── issue_template.md
```
