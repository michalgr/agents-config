# agents-config

Shared AI agent rules (`AGENTS.md`) and custom skills (`skills/`) used across:
- **[`.dotfiles`](https://github.com/michalgr/.dotfiles)** (macOS host environment, managed via GNU Stow and Git submodule)
- **[`agent-jail`](https://github.com/michalgr/agent-jail)** (containerized Nix environment, managed via Nix Flakes and Home Manager)

## Structure

```text
agents-config/
├── .stow-local-ignore             # Excludes repo metadata when stowed
├── README.md
├── AGENTS.md                      # Global agent rules & coding guidelines
└── skills/                        # Harness-agnostic agent skills
    └── jules/                     # Workflow for delegating tasks to Google's Jules agent
        ├── SKILL.md
        ├── references/
        │   └── issue_template.md
        └── scripts/
            ├── check_jules_pr.sh
            └── create_jules_issue.sh
```
