#!/usr/bin/env bash
# Watcher for the vercel-feedback skill (/ctotools:vercel-feedback ... watch).
# Polls a branch's unresolved Vercel Toolbar threads and prints one line each time a
# thread needs attention: it's new, or someone other than this skill wrote in it last.
# Each line is an event for Claude Code's Monitor tool.
#
# Usage: bash watch.sh <team> <project> <branch> [interval seconds, default 30]

set -u
team=$1 project=$2 branch=$3 interval=${4:-30}
seen=$(mktemp)
trap 'rm -f "$seen"' EXIT

while true; do
  cursor=""
  while :; do
    page=$(vercel comments list --scope "$team" -p "$project" --branch "$branch" \
      --json --limit 100 ${cursor:+--next "$cursor"} 2>/dev/null) || {
      echo "poll failed, retrying in ${interval}s" >&2
      break
    }
    # Skip threads whose last message is this skill's reply. The list gives plain
    # text, so "**Addressed in**" arrives as "Addressed in".
    jq -r '.threads[]
      | .messages[-1] as $m
      | select(($m.text | test("^(Addressed in|Question:)")) | not)
      | [.id, $m.id, (.context.path // "?"), ($m.author.username // "?"),
         ($m.text | gsub("\\s+"; " ") | .[0:80])]
      | @tsv' <<<"$page" |
      while IFS=$'\t' read -r thread msg path author text; do
        grep -qxF "$thread:$msg" "$seen" && continue
        echo "$thread:$msg" >>"$seen"
        echo "comment $thread on $path from $author: $text"
      done
    cursor=$(jq -r '.pagination.nextCursor // empty' <<<"$page")
    [ -n "$cursor" ] || break
  done
  sleep "$interval"
done
