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
echo "== Upstream =="
print_cmd "git rev-parse --abbrev-ref --symbolic-full-name @{u}"
if git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then
  print_cmd "git --no-pager log --oneline --decorate --reverse @{u}..HEAD"
  log=$(git --no-pager log --oneline --decorate --reverse @{u}..HEAD)
  if [ -z "$log" ]; then
    echo "(no commits ahead of upstream)"
  else
    printf '%s\n' "$log"
  fi
else
  echo "(no upstream set) showing last 10 commits"
  print_cmd "git --no-pager log --oneline --decorate -n 10"
  git --no-pager log --oneline --decorate -n 10
fi
