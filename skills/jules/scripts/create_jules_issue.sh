#!/usr/bin/env bash
# create_jules_issue.sh
# Creates a GitHub issue with the 'jules' label to delegate tasks to Jules.
# Automatically fetches and appends the published global coding, testing, and
# documentation rules from GitHub (never from local files) to prevent local leaks.
#
# Module Master Plan:
# 1. Definitions: Declare CLI flags, shared rule paths, and section constants.
# 2. Entry Point (`main`): Orchestrate argument parsing, input/auth validation,
#    published global rule resolution, and GitHub issue dispatch.
# 3. Helper Functions:
#    - `usage` / `parse_args` / `resolve_issue_body` / `validate_inputs`: Parse
#      flags, enforce the `--confirmed` gate, and validate non-empty title/body.
#    - `verify_gh_ready`: Ensure `gh` is installed and authenticated.
#    - `demote_markdown_headings` / `fetch_published_rules` / `append_global_rules`:
#      Fetch published rule files from GitHub via `gh api`, demote ATX headings
#      outside fenced code blocks, and append to `FINAL_BODY`.
#    - `dispatch_jules_issue`: Create the `jules` label idempotently, create the
#      issue via stdin, and emit machine-readable JSON on stdout.

set -euo pipefail

# ==============================================================================
# 1. Definitions
# ==============================================================================

TITLE=""
BODY=""
BODY_FILE=""
FINAL_BODY=""
HAS_BODY=false
HAS_BODY_FILE=false
REPO_ARGS=()
RULES_REPO="michalgr/agents-config"
RULES_REF="main"
APPEND_GLOBAL_RULES=true
CONFIRMED=false

GLOBAL_SECTION_HEADER="## Global Coding, Testing, and Documentation Guidelines"
SHARED_RULE_PATHS=(
  "rules/code-structure.md"
  "rules/testing.md"
  "rules/documentation.md"
)

# ==============================================================================
# 2. Entry Point
# ==============================================================================

main() {
  parse_args "$@"
  validate_inputs
  verify_gh_ready
  append_global_rules
  dispatch_jules_issue
}

# ==============================================================================
# 3. Helper Functions
# ==============================================================================

# Prints CLI usage instructions and exits with the given status code.
usage() {
  local exit_code="${1:-1}"
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  -t, --title <title>          Issue title (required)
  -b, --body <body>            Issue body markdown content
  -f, --body-file <file>       Path to markdown file with issue body
  -R, --repo <owner/repo>      Target repository (defaults to current git repo)
  --rules-repo <owner/repo>    GitHub repository hosting shared rules (default: michalgr/agents-config)
  --rules-ref <ref>            Git ref/branch for shared rules on GitHub (default: main)
  --no-global-rules            Do not automatically fetch and append published global rules from GitHub
  -c, --confirmed              Confirm that the user explicitly approved the plan artifact (required)
  -h, --help                   Show this help message

Examples:
  $(basename "$0") -t "Fix worker pool memory leak" -f ./issue.md --confirmed
  $(basename "$0") -t "Add unit test for parser" -b "Details here..." --confirmed
EOF
  exit "$exit_code"
}

# Parses CLI flags into module-level configuration variables.
parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -t|--title)
        [[ $# -ge 2 ]] || { echo "Error: $1 requires an argument." >&2; usage; }
        TITLE="$2"
        shift 2
        ;;
      -b|--body)
        [[ $# -ge 2 ]] || { echo "Error: $1 requires an argument." >&2; usage; }
        BODY="$2"
        HAS_BODY=true
        shift 2
        ;;
      -f|--body-file)
        [[ $# -ge 2 ]] || { echo "Error: $1 requires an argument." >&2; usage; }
        BODY_FILE="$2"
        HAS_BODY_FILE=true
        shift 2
        ;;
      -R|--repo)
        [[ $# -ge 2 ]] || { echo "Error: $1 requires an argument." >&2; usage; }
        REPO_ARGS=(--repo "$2")
        shift 2
        ;;
      --rules-repo)
        [[ $# -ge 2 ]] || { echo "Error: $1 requires an argument." >&2; usage; }
        RULES_REPO="$2"
        shift 2
        ;;
      --rules-ref)
        [[ $# -ge 2 ]] || { echo "Error: $1 requires an argument." >&2; usage; }
        RULES_REF="$2"
        shift 2
        ;;
      --no-global-rules)
        APPEND_GLOBAL_RULES=false
        shift
        ;;
      -c|--confirmed)
        CONFIRMED=true
        shift
        ;;
      -h|--help)
        usage 0
        ;;
      *)
        echo "Unknown option: $1" >&2
        usage
        ;;
    esac
  done
}

# Resolves FINAL_BODY from either --body or --body-file and ensures it is non-empty.
resolve_issue_body() {
  if [[ "$HAS_BODY_FILE" == true ]]; then
    if [[ ! -f "$BODY_FILE" ]]; then
      echo "Error: Body file '$BODY_FILE' does not exist." >&2
      exit 1
    fi
    FINAL_BODY="$(cat "$BODY_FILE")"
  else
    FINAL_BODY="$BODY"
  fi

  if [[ ! "$FINAL_BODY" =~ [^[:space:]] ]]; then
    echo "Error: Issue body must not be empty." >&2
    exit 1
  fi
}

# Validates the mandatory approval gate, non-empty title, and mutually exclusive body flags.
validate_inputs() {
  if [[ "$CONFIRMED" != true ]]; then
    echo "Error: The --confirmed flag is required. You must obtain explicit user approval on the plan artifact before dispatching this issue to Jules." >&2
    exit 1
  fi

  if [[ ! "$TITLE" =~ [^[:space:]] ]]; then
    echo "Error: --title is required and must not be empty." >&2
    usage
  fi

  if [[ "$HAS_BODY" != true && "$HAS_BODY_FILE" != true ]]; then
    echo "Error: Either --body or --body-file must be provided." >&2
    usage
  fi

  if [[ "$HAS_BODY" == true && "$HAS_BODY_FILE" == true ]]; then
    echo "Error: Provide either --body or --body-file, not both." >&2
    usage
  fi

  resolve_issue_body
}

# Verifies that the GitHub CLI is installed and authenticated.
verify_gh_ready() {
  if ! command -v gh >/dev/null 2>&1; then
    echo "Error: 'gh' (GitHub CLI) is not installed or not in PATH." >&2
    exit 1
  fi

  if ! gh auth status >/dev/null 2>&1; then
    echo "Error: 'gh' is not authenticated. Run 'gh auth login' first." >&2
    exit 1
  fi
}

# Pure filter: demotes ATX markdown headings by two levels outside fenced code blocks.
demote_markdown_headings() {
  awk '
    /^(```+|~~~+)/ { in_fence = !in_fence }
    !in_fence && /^#+[[:space:]]/ { $0 = "##" $0 }
    { print }
  '
}

# Fetches and concatenates published global rule files from GitHub.
fetch_published_rules() {
  local fetched="" rule_path rule_content demoted_content
  for rule_path in "${SHARED_RULE_PATHS[@]}"; do
    if rule_content="$(gh api -X GET -H "Accept: application/vnd.github.raw" "/repos/${RULES_REPO}/contents/${rule_path}" -f ref="$RULES_REF" 2>/dev/null)"; then
      demoted_content="$(printf '%s\n' "$rule_content" | demote_markdown_headings)"
      fetched="${fetched:+${fetched}$'\n\n'}${demoted_content}"
    else
      echo "Warning: Could not fetch published rule '${rule_path}' from ${RULES_REPO}@${RULES_REF} on GitHub; skipping inline append for this file." >&2
    fi
  done
  printf '%s' "$fetched"
}

# Appends the published global rules section to FINAL_BODY when enabled and not already present.
append_global_rules() {
  if [[ "$APPEND_GLOBAL_RULES" != true || "$FINAL_BODY" == *"$GLOBAL_SECTION_HEADER"* ]]; then
    return 0
  fi

  local fetched_rules
  fetched_rules="$(fetch_published_rules)"
  if [[ -z "$fetched_rules" ]]; then
    echo "Error: Failed to fetch any published global rules from ${RULES_REPO}@${RULES_REF}. Verify --rules-repo/--rules-ref or pass --no-global-rules." >&2
    exit 1
  fi

  FINAL_BODY="${FINAL_BODY}"$'\n\n---\n\n'"${GLOBAL_SECTION_HEADER}"$'\n\n> Automatically fetched from [`'"${RULES_REPO}@${RULES_REF}"'`](https://github.com/'"${RULES_REPO}"'/tree/'"${RULES_REF}"'/rules)\n\n'"${fetched_rules}"
}

# Ensures the 'jules' label exists, creates the GitHub issue, and prints JSON output.
dispatch_jules_issue() {
  gh label create jules --description "Tasks delegated to Jules agent" --color "0E8A16" --force "${REPO_ARGS[@]}" >/dev/null 2>&1 || true

  echo "Creating GitHub issue tagged for Jules..." >&2
  local issue_url issue_num
  issue_url="$(printf '%s\n' "$FINAL_BODY" | gh issue create --title "$TITLE" --body-file - --label "jules" "${REPO_ARGS[@]}")"
  if [[ -z "$issue_url" ]]; then
    echo "Error: Failed to create issue." >&2
    exit 1
  fi

  issue_num="$(basename "$issue_url")"
  echo "Created Jules issue successfully!" >&2
  echo "Issue Number: $issue_num" >&2
  echo "Issue URL:    $issue_url" >&2

  cat <<EOF
{
  "status": "created",
  "issue_number": "$issue_num",
  "issue_url": "$issue_url"
}
EOF
}

main "$@"
