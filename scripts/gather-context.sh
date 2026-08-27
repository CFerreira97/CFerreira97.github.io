#!/usr/bin/env bash
# gather-context.sh -- deterministic raw material for the research subagent
# to turn into docs/context-wiki/ pages. Prints to stdout; doesn't write anything.
#
# Usage: ./gather-context.sh
#
# Kept as plain shell (not an LLM call) so the *gathering* is cheap, repeatable,
# and cache-friendly -- only the curation step (deciding what's worth a wiki
# page, and writing it well) needs a model.
set -euo pipefail

echo "# Raw project context (generated $(date -u +%Y-%m-%dT%H:%M:%SZ))"
echo

echo "## File tree"
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git ls-files | sort
else
  find . -type f -not -path '*/.git/*' | sed 's|^\./||' | sort
fi
echo

for f in README.md CLAUDE.md pyproject.toml package.json go.mod; do
  if [ -f "$f" ]; then
    echo "## $f"
    cat "$f"
    echo
  fi
done

if [ -d docs ]; then
  echo "## docs/ tree"
  find docs -type f -name '*.md' | sort
  echo
fi

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "## Recent commits (last 20)"
  git log --oneline -20
  echo
fi
