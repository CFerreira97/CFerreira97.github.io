#!/usr/bin/env bash
# Squash-merge a PR and verify the cleanup GitHub is unreliable about:
# - refuses production-base (master/main) PRs without a recorded user approval
#   (~/dev/agents/review-queue/<repo>/approvals/<pr>), consuming it on success
# - verifies --delete-branch actually removed the remote head; deletes it if not
# - with --issue N: verifies the merge closed the issue; closes it if not
# Prints one JSON result. Usage: merge-verify.sh <pr-number> [--issue N]
set -euo pipefail

pr="${1:?usage: merge-verify.sh <pr-number> [--issue N]}"
issue=""
if [ "${2:-}" = "--issue" ]; then
  issue="${3:?--issue needs a number}"
fi

info="$(gh pr view "$pr" --json number,headRefName,baseRefName,state)"
num="$(jq -r .number <<<"$info")"
head="$(jq -r .headRefName <<<"$info")"
base="$(jq -r .baseRefName <<<"$info")"
state="$(jq -r .state <<<"$info")"

if [ "$state" != "OPEN" ]; then
  echo "PR #$num is $state, not open" >&2
  exit 1
fi

marker=""
case "$base" in
  master|main)
    repo="$(gh repo view --json name -q .name)"
    marker="$HOME/dev/agents/review-queue/$repo/approvals/$num"
    if [ ! -f "$marker" ]; then
      echo "PR #$num targets $base (production) and has no recorded approval at $marker -- get the user's approval first (review dashboard or explicit ok)" >&2
      exit 1
    fi
    ;;
esac

gh pr merge "$num" --squash --delete-branch
merge_sha="$(gh pr view "$num" --json mergeCommit -q .mergeCommit.oid)"

head_deleted=true
if [ -n "$(git ls-remote --heads origin "$head")" ]; then
  git push origin --delete "$head"
  head_deleted="cleaned-up-manually"
fi

issue_state=""
if [ -n "$issue" ]; then
  issue_state="$(gh issue view "$issue" --json state -q .state)"
  if [ "$issue_state" = "OPEN" ]; then
    gh issue close "$issue" --comment "Closed by merge of PR #$num ($merge_sha)."
    issue_state="closed-manually"
  fi
fi

[ -n "$marker" ] && rm -f "$marker"

jq -n --arg pr "$num" --arg sha "$merge_sha" --arg head "$head" \
  --arg hd "$head_deleted" --arg is "$issue_state" \
  '{merged: true, pr: ($pr | tonumber), merge_sha: $sha, head_branch: $head,
    head_deleted: $hd, issue_state: (if $is == "" then null else $is end)}'
