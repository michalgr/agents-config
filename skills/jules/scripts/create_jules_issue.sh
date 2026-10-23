#!/usr/bin/env bash
# create_jules_issue.sh
# Creates a GitHub issue with the 'jules' label to delegate tasks to Jules.

set -euo pipefail

usage() {
  local exit_code="${1:-1}"
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  -t, --title <title>          Issue title (required)
  -b, --body <body>            Issue body markdown content
  -f, --body-file <file>       Path to markdown file with issue body
  -R, --repo <owner/repo>      Target repository (defaults to current git repo)
  -c, --confirmed              Confirm that the user explicitly approved the plan artifact (required)
  -h, --help                   Show this help message

Examples:
  $(basename "$0") -t "Fix worker pool memory leak" -f ./issue.md --confirmed
  $(basename "$0") -t "Add unit test for parser" -b "Details here..." --confirmed
EOF
  exit "$exit_code"
}

TITLE=""
BODY=""
BODY_FILE=""
REPO_ARGS=()
CONFIRMED=false

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
      shift 2
      ;;
    -f|--body-file)
      [[ $# -ge 2 ]] || { echo "Error: $1 requires an argument." >&2; usage; }
      BODY_FILE="$2"
      shift 2
      ;;
    -R|--repo)
      [[ $# -ge 2 ]] || { echo "Error: $1 requires an argument." >&2; usage; }
      REPO_ARGS=(--repo "$2")
      shift 2
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

if [[ "$CONFIRMED" != true ]]; then
  echo "Error: The --confirmed flag is required. You must obtain explicit user approval on the plan artifact before dispatching this issue to Jules." >&2
  exit 1
fi

if [[ -z "$TITLE" ]]; then
  echo "Error: --title is required." >&2
  usage
fi

if [[ -z "$BODY" && -z "$BODY_FILE" ]]; then
  echo "Error: Either --body or --body-file must be provided." >&2
  usage
fi

if [[ -n "$BODY_FILE" ]]; then
  if [[ ! -f "$BODY_FILE" ]]; then
    echo "Error: Body file '$BODY_FILE' does not exist." >&2
    exit 1
  fi
  BODY_ARGS=(--body-file "$BODY_FILE")
else
  BODY_ARGS=(--body "$BODY")
fi

# 1. Verify GitHub CLI is available
if ! command -v gh >/dev/null 2>&1; then
  echo "Error: 'gh' (GitHub CLI) is not installed or not in PATH." >&2
  exit 1
fi

# 2. Check auth status
if ! gh auth status >/dev/null 2>&1; then
  echo "Error: 'gh' is not authenticated. Run 'gh auth login' first." >&2
  exit 1
fi

# 3. Ensure 'jules' label exists
if ! gh label list "${REPO_ARGS[@]}" --limit 100 2>/dev/null | grep -qw "jules"; then
  echo "Label 'jules' not found. Creating label 'jules'..." >&2
  gh label create jules --description "Tasks delegated to Jules agent" --color "0E8A16" --force "${REPO_ARGS[@]}" >/dev/null 2>&1 || true
fi

# 4. Create the issue
echo "Creating GitHub issue tagged for Jules..." >&2
ISSUE_URL=$(gh issue create --title "$TITLE" "${BODY_ARGS[@]}" --label "jules" "${REPO_ARGS[@]}")

if [[ -z "$ISSUE_URL" ]]; then
  echo "Error: Failed to create issue." >&2
  exit 1
fi

ISSUE_NUM=$(basename "$ISSUE_URL")

echo "Created Jules issue successfully!" >&2
echo "Issue Number: $ISSUE_NUM" >&2
echo "Issue URL:    $ISSUE_URL" >&2

# Output machine-readable JSON for agent consumption on stdout
cat <<EOF
{
  "status": "created",
  "issue_number": "$ISSUE_NUM",
  "issue_url": "$ISSUE_URL"
}
EOF
