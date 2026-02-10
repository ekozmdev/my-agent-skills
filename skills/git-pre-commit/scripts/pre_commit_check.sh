#!/usr/bin/env bash
set -euo pipefail

print_cmd() {
  printf '$ %s\n' "$*"
}

run() {
  print_cmd "$*"
  "$@"
}

print_cmd "git rev-parse --is-inside-work-tree"
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Not a git repository (run inside a repo)."
  exit 1
fi

echo "== Branch =="
run git --no-pager branch

echo
echo "== Status =="
run git --no-pager status --short

echo
echo "== Staged diff =="
print_cmd "git --no-pager diff --staged --quiet"
if git diff --staged --quiet; then
  echo "(no staged changes)"
else
  run git --no-pager diff --staged
fi

echo
echo "== Worktree diff =="
print_cmd "git --no-pager diff --quiet"
if git diff --quiet; then
  echo "(no unstaged changes)"
else
  run git --no-pager diff
fi
