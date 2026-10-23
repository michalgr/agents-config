# Issue Template for Jules Delegation

Use this template to compile structured GitHub issues when delegating tasks to Jules.
Jules executes autonomously inside a cloud container, so providing concrete, reproducible instructions yields the highest success rate.

```markdown
## Overview
<!-- Concise description of the issue, bug, or requested feature -->

## Context & Key Locations
<!-- Provide repository-relative paths and line references identified during local research -->
- Target Files:
  - `path/to/file.ext:lines`
- Existing Test Files:
  - `path/to/test.ext:lines`

## Current Behavior
<!-- What is currently happening or missing -->

## Expected Behavior
<!-- What should happen after the changes are implemented -->

## Acceptance Criteria
- [ ] Implement the fix / feature as described.
- [ ] Preserve existing public API and backward compatibility.
- [ ] Add or update unit tests covering this case.
- [ ] Ensure all existing tests pass.

## Verification & Test Commands
<!-- The exact commands Jules should run in its cloud VM to reproduce and verify -->
```bash
<test-command-here>
```

## Architectural & Style Constraints
<!-- Inline any repo-specific patterns (from the repo's AGENTS.md) as well as relevant global design, documentation, and language rules from your global AGENTS.md (excluding interactive commit restrictions) -->
- Follow conventions established in the repository's `AGENTS.md`.
- Prefer proper, maintainable fixes over short-term hacks or workarounds.
- Ensure all code, comments, docstrings, and commit messages are in English.
```
