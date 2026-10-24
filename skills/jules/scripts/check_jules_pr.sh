#!/usr/bin/env bash
# check_jules_pr.sh
# Finds and checks status of PRs created by Jules for an issue or branch.
#
# Module Master Plan:
# 1. Definitions: Declare CLI configuration state and defaults.
# 2. Entry Point (`main`): Orchestrate argument parsing, validation, PR discovery,
#    and status/CI/diff reporting.
# 3. Helper Functions:
#    - `usage` / `parse_numeric_id` / `parse_args` / `validate_inputs`: Parse and
#      validate CLI options and verify `gh` availability.
#    - `find_pr_by_issue` / `find_latest_jules_pr` / `resolve_pr_number`: Discover
#      the target PR via `gh pr list` + `jq`, prioritizing `OPEN` PRs.
#    - `report_pr_status`: Emit waiting JSON when no PR exists, or print PR
#      metadata, optional CI checks, and optional diff stats.

set -euo pipefail

# ==============================================================================
# 1. Definitions
# ==============================================================================

ISSUE_NUM=""
PR_NUM=""
REPO_ARGS=()
CHECK_CI=false
CHECK_DIFF=false

# ==============================================================================
# 2. Entry Point
# ==============================================================================

main() {
  parse_args "$@"
  validate_inputs
  resolve_pr_number
  report_pr_status
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
  -i, --issue <number>       GitHub issue number to find associated PR
  -p, --pr <number>          Specific PR number to inspect
  -R, --repo <owner/repo>    Target repository (defaults to current git repo)
  --checks                   Also inspect and report CI status checks
  --diff-stat                Show summary of modified files in the PR
  -h, --help                 Show this help message

Examples:
  $(basename "$0") -i 42
  $(basename "$0") -p 43 --checks
EOF
  exit "$exit_code"
}

# Strips an optional leading '#' and verifies that an issue/PR identifier is numeric.
parse_numeric_id() {
  local flag="$1"
  local raw="$2"
  local cleaned="${raw#\#}"
  if [[ ! "$cleaned" =~ ^[0-9]+$ ]]; then
    echo "Error: ${flag} requires a numeric number (got '${raw}')." >&2
    exit 1
  fi
  printf '%s' "$cleaned"
}

# Parses CLI flags into module-level configuration variables.
parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -i|--issue)
        [[ $# -ge 2 ]] || { echo "Error: $1 requires an argument." >&2; usage; }
        ISSUE_NUM="$(parse_numeric_id "--issue" "$2")"
        shift 2
        ;;
      -p|--pr)
        [[ $# -ge 2 ]] || { echo "Error: $1 requires an argument." >&2; usage; }
        PR_NUM="$(parse_numeric_id "--pr" "$2")"
        shift 2
        ;;
      -R|--repo)
        [[ $# -ge 2 ]] || { echo "Error: $1 requires an argument." >&2; usage; }
        REPO_ARGS=(--repo "$2")
        shift 2
        ;;
      --checks)
        CHECK_CI=true
        shift
        ;;
      --diff-stat)
        CHECK_DIFF=true
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

# Enforces mutual exclusion of --issue and --pr and checks for the GitHub CLI.
validate_inputs() {
  if [[ -n "$ISSUE_NUM" && -n "$PR_NUM" ]]; then
    echo "Error: Provide either --issue or --pr, not both." >&2
    usage
  fi

  if ! command -v gh >/dev/null 2>&1; then
    echo "Error: 'gh' (GitHub CLI) is not installed or not in PATH." >&2
    exit 1
  fi
}

# Queries `gh pr list` for a PR referencing ISSUE_NUM in its title, body, or branch name,
# prioritizing OPEN PRs over closed/merged attempts.
find_pr_by_issue() {
  gh pr list "${REPO_ARGS[@]}" --state all --json number,state,title,body,headRefName \
    -q "([.[] | select(
      ((.title + \" \" + (.body // \"\")) | test(\"(?i)(#|(^|[^0-9a-z])issues?[-_ /]#?)${ISSUE_NUM}([^0-9]|$)\"))
      or (.headRefName | test(\"(^|[^0-9])${ISSUE_NUM}([^0-9]|$)\"))
    )] | sort_by(if .state == \"OPEN\" then 0 else 1 end, -.number))[0].number // empty"
}

# Queries `gh pr list` for the latest PR from a `jules` branch prefix, prioritizing OPEN PRs.
find_latest_jules_pr() {
  gh pr list "${REPO_ARGS[@]}" --state all --json number,state,headRefName \
    -q '([.[] | select(.headRefName | test("(?i)^jules([/-]|$)"))] | sort_by(if .state == "OPEN" then 0 else 1 end, -.number))[0].number // empty'
}

# Resolves PR_NUM via issue discovery or branch fallback when --pr is not explicitly given.
resolve_pr_number() {
  [[ -z "$PR_NUM" ]] || return 0
  if [[ -n "$ISSUE_NUM" ]]; then
    PR_NUM="$(find_pr_by_issue)"
  else
    PR_NUM="$(find_latest_jules_pr)"
  fi
}

# Outputs JSON status when waiting, or prints PR metadata, optional CI checks, and diff stats.
report_pr_status() {
  if [[ -z "$PR_NUM" || "$PR_NUM" == "null" ]]; then
    echo '{"status": "waiting_for_pr", "message": "No Jules pull request found yet."}'
    exit 0
  fi

  local pr_info
  pr_info="$(gh pr view "$PR_NUM" "${REPO_ARGS[@]}" --json number,title,state,isDraft,url,headRefName,author)"
  echo "Found PR #$PR_NUM" >&2
  echo "$pr_info"

  if [[ "$CHECK_CI" == true ]]; then
    echo "--- CI Checks ---" >&2
    gh pr checks "$PR_NUM" "${REPO_ARGS[@]}" || true
  fi

  if [[ "$CHECK_DIFF" == true ]]; then
    echo "--- Diff Stat ---" >&2
    gh pr diff "$PR_NUM" "${REPO_ARGS[@]}" --stat || true
  fi
}

main "$@"
