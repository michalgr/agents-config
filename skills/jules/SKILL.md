---
name: jules
description: >-
  Delegates implementation tasks, bug fixes, or feature requests to Jules (Google's asynchronous GitHub coding agent)
  via GitHub issues and pull requests. Activate when the user invokes '/jules <task>' or asks to delegate work to Jules.
---

# Jules Delegation Workflow (`/jules`)

This skill guides the agent through delegating development tasks to **Jules**, Google's asynchronous AI coding agent that runs in cloud virtual machines directly on GitHub repositories.

> [!NOTE]
> All relative paths in this skill (`./references/...`, `./scripts/...`) are relative to the directory containing this `SKILL.md` file (`<skill-dir>`).

Delegation follows a 6-step lifecycle:
1. **Local Research & Git Sanity**: Rapid local analysis without modifying source code.
2. **Brainstorming & User Alignment**: Discussing details and trade-offs with the user (unless trivial).
3. **Plan Artifact Formulation**: Drafting the issue sketch/plan as an artifact with `RequestFeedback: true`.
4. **MANDATORY APPROVAL GATE (STOP)**: Yielding the turn immediately and awaiting explicit user approval.
5. **Issue Dispatch & Async Tracking**: Creating the GitHub issue with `--confirmed` and non-blocking monitoring.
6. **CI & Automated Review**: Inspecting Jules's pull request, checking CI test suites, and delivering an explicit verdict.

--------------------------------------------------------------------------------

## Phase 1: Local Research & Git Sanity

Before delegating to Jules, investigate the problem locally using read-only tools. **Do not modify source files directly.**

1. **Verify Git Tree State**:
   - Run `git status` and `git diff --stat origin/HEAD` (or `origin/main`).
   - *Crucial*: Jules checks out the remote branch from GitHub. If the user has relevant uncommitted or unpushed local changes, alert them immediately:
     > "Jules operates on the remote GitHub repository. You have unpushed local changes that Jules won't see. Would you like to commit/push them to a branch first?"

2. **Conduct Codebase Investigation**:
   - Use your read-only search and file-viewing tools (e.g., `grep_search` / `ripgrep`, `find_by_name` / `fd`, `view_file` / `read_file`) to locate:
     - Exact target files and line ranges.
     - Existing test files covering the relevant modules.
     - Reproducible commands (e.g. `cargo test`, `pytest`, `go test ./...`, `npm test`).
   - Identify any constraints, API stability requirements, or style guidelines in both the repository's `AGENTS.md` and your global `AGENTS.md`.

--------------------------------------------------------------------------------

## Phase 2: Brainstorming & Drafting the Plan Artifact

Jules operates in a cloud VM and achieves the highest success rate when given explicit constraints and test commands rather than broad prompts.

1. **Brainstorm with the User (Unless Trivial)**:
   - For non-trivial tasks (multiple implementation approaches, ambiguous scope, architectural trade-offs, or API design), actively discuss and brainstorm the details with the user first.
   - Align on the chosen approach, trade-offs, and edge cases before drafting.
   - For trivial, unambiguous tasks (e.g. self-evident fix with a single obvious solution), brainstorming can be skipped, but the plan artifact must still be presented.

2. **Write the Plan as an Artifact for Review**:
   - Format the proposed issue following [references/issue_template.md](./references/issue_template.md).
   - **In Antigravity**: Create a user-facing **Artifact** (e.g., `<appDataDir>/brain/<conversation-id>/jules_plan.md`) via `write_file` / `write_to_file` and provide `ArtifactMetadata` with:
     ```json
     {
       "RequestFeedback": true,
       "UserFacing": true,
       "Summary": "Jules delegation plan and draft GitHub issue for review"
     }
     ```
   - **In other agent harnesses** (where `ArtifactMetadata` is not supported): Write the draft issue to a temporary markdown file (or present it in chat) and ask the user for explicit approval before proceeding.
   - Content must include:
     - **Overview & Motivation**
     - **Target Files & Line Ranges**
     - **Acceptance Criteria Checklist**
     - **Verification / Test Commands**
     - **Constraints & Architectural Rules** (document repo-specific patterns from the target repository's `AGENTS.md` and keep the canonical GitHub links to `rules/code-structure.md`, `rules/testing.md`, and `rules/documentation.md`; note that `create_jules_issue.sh` automatically fetches and appends their published online contents from GitHub at dispatch time)

--------------------------------------------------------------------------------

## Phase 3: MANDATORY APPROVAL GATE (Hard Stop)

> [!CAUTION]
> **CRITICAL: NEVER FILE THE ISSUE IN THE SAME TURN AS CREATING THE ARTIFACT.**
>
> 1. **Immediate Turn End**: After creating or updating the plan artifact, you MUST STOP calling tools immediately. Output a message pointing the user to the artifact and end your turn.
> 2. **No Tool Chaining**: You are **STRICTLY FORBIDDEN** from invoking `create_jules_issue.sh`, `gh issue create`, or any command that creates an issue within the same turn that created or edited the artifact.
> 3. **Wait for Subsequent User Message**: You must wait for the user to explicitly review the artifact and reply in a new turn (e.g., clicking "Proceed", saying "approved", "looks good", or "file it").
> 4. If the user requests changes, update the artifact and repeat the approval gate.

--------------------------------------------------------------------------------

## Phase 4: Issue Dispatch (Subsequent Turn Only)

**Execute this phase ONLY after receiving explicit user approval in a subsequent message.**

1. **Dispatch via Helper Script**:
   - Call the helper script (located at `./scripts/create_jules_issue.sh` relative to this skill directory) with the `--confirmed` flag:
     ```bash
     <skill-dir>/scripts/create_jules_issue.sh \
       --title "Fix: <Concise title>" \
       --body "<Formatted issue content>" \
       --confirmed
     ```
   - *Note*: `create_jules_issue.sh` will fail if `--confirmed` is omitted.
2. **Report Dispatch to User**:
   - Provide the issue number and clickable URL.
   - Confirm that Jules has been summoned via the `jules` label.

--------------------------------------------------------------------------------

## Phase 5: Async Lifecycle (Non-Blocking)

Jules takes between 5 to 15 minutes to clone, build, attempt fixes, and run tests.

> [!WARNING]
> **NEVER run an active spin-lock (`sleep 10` or continuous polling loop)** in the chat. Busy-waiting consumes unnecessary tokens and blocks the user from asking further questions.

1. **Initial Status Check**:
   - Check if a PR already exists (unlikely in the first 60 seconds, but verify):
     ```bash
     <skill-dir>/scripts/check_jules_pr.sh --issue <ISSUE_NUMBER>
     ```
2. **Yield Control with Scheduling**:
   - If the PR is not ready, inform the user:
     > "Issue #<N> has been created and tagged for Jules. Jules is analyzing the repo and running tests in its cloud VM. You can continue working; I will check back, or you can run `/jules check <ISSUE_NUMBER>` anytime."
   - If in an environment that supports one-shot reminders, schedule a check after 5 minutes rather than looping.

--------------------------------------------------------------------------------

## Phase 6: CI & Automated Code Review

Once Jules opens a Pull Request:

1. **Inspect PR & CI Status**:
   ```bash
   <skill-dir>/scripts/check_jules_pr.sh --issue <ISSUE_NUMBER> --checks --diff-stat
   ```
   Or via `gh`:
   ```bash
   gh pr view <PR_NUMBER>
   gh pr checks <PR_NUMBER>
   ```

2. **Conduct Automated Review of the PR Diff**:
   - Read the diff:
     ```bash
     gh pr diff <PR_NUMBER>
     ```
   - Evaluate against the original **Acceptance Criteria** and the **Global Agent Guidelines**:
     - Did Jules modify the expected files without unintended side-effects?
     - Are any unexpected files changed or deleted?
     - Did Jules add or update tests?
     - Did CI pass without errors or warnings?
     - **Code Structure (`rules/code-structure.md`)**: Are functions structured as high-level Theorems and pure Lemmas ($\le 25$ lines, with cohesion exceptions) in `Definitions → Theorems → Lemmas` reading order, using narrow domain types and boundary assertions, and keeping modules within the 400 / 800 / 1,200-line thresholds (with a Subsystem Table of Contents when multi-module)?
     - **Testing (`rules/testing.md`)**: Are tests written as concise worked examples using shared test lemmas/fixtures rather than copy-paste boilerplate?
     - **Commentary & Documentation (`rules/documentation.md`)**: Do modified/new modules include a non-docstring **Module Master Plan** comment at the top and contextualizing non-docstring comments on classes/functions (kept in sync without drift), with clean separation of docstrings vs. implementation comments?

3. **Formulate Explicit Verdict & Merge Recommendation**:
   Deliver a definitive recommendation with one of three outcomes:
   - **Merge As-Is**:
     - *When to use*: All acceptance criteria are satisfied, CI checks pass cleanly, and the design adheres to repository guidelines without regressions.
     - *Command*:
       ```bash
       gh pr merge <PR_NUMBER> --squash
       ```
   - **Request Changes (Explicitly State What Is Wrong)**:
     - *When to use*: Core acceptance criteria failed, tests or CI are failing, logic bugs or regressions were introduced, or architectural/security rules were violated.
     - *Action*: Explicitly detail what is broken, why it is incorrect, and post or propose a changes-requested review for Jules:
       ```bash
       gh pr review <PR_NUMBER> --request-changes --body "<Detailed breakdown of what is wrong and required fixes>"
       ```
   - **Merge with Follow-Up Fixes & Nits**:
     - *When to use*: The primary fix/feature is functionally correct and solid, but minor cosmetic issues, formatting nits, documentation polish, or small refactor opportunities remain.
     - *Action*: Do not block the PR for minor issues. Recommend merging the PR and explicitly enumerate the suggested nits/follow-up items to address locally or in a subsequent task.

4. **Present Review Summary to the User**:
   - **PR Overview**: Link, title, and branch name (`jules/...`).
   - **CI Status**: Pass/fail breakdown of checks.
   - **Diff Assessment**: Files modified, test coverage added.
   - **Verdict**: Clearly state **Merge As-Is**, **Request Changes**, or **Merge with Follow-Up Nits**.
   - **Next Steps & Checkout**:
     ```bash
     gh pr checkout <PR_NUMBER>
     ```
