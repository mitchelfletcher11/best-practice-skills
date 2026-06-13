#!/bin/bash
NOW=$(date +%s)
THRESHOLD=86400

check_due() {
  local gate="$1"
  [ ! -f "$gate" ] && return 0
  local ts
  ts=$(date -d "$(cat "$gate")" +%s 2>/dev/null) || return 0
  [ $((NOW - ts)) -ge $THRESHOLD ] && return 0
  return 1
}

MSGS=()
check_due "$HOME/.claude/skills/best-practice-claude/last-check.md" && MSGS+=("/best-practice-claude")
check_due "$HOME/.claude/skills/best-practice-skills/last-check.md"  && MSGS+=("/best-practice-skills")

if [ ${#MSGS[@]} -gt 0 ]; then
  echo "Before addressing this message, run: ${MSGS[*]}"
fi
