#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$script_dir/lib.sh"

usage() {
  cat <<'USAGE'
Usage: tail-pane.sh target [options]

Poll and print recent pane output for a bounded amount of time.

Options:
  -s, --session NAME   Session to search for pane titles.
  -S, --seconds N      Seconds to follow. Default: 20.
  -i, --interval N     Poll interval seconds. Default: 1.
  -l, --lines N        Lines to capture each poll. Default: 80.
  -h, --help           Show this help.
USAGE
}

target_query=''
session=''
seconds='20'
interval='1'
lines='80'

while [[ $# -gt 0 ]]; do
  case "$1" in
    -s|--session) session="${2-}"; shift 2 ;;
    -S|--seconds) seconds="${2-}"; shift 2 ;;
    -i|--interval) interval="${2-}"; shift 2 ;;
    -l|--lines) lines="${2-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    -*) tmux_skill_die "unknown option: $1" ;;
    *) target_query="$1"; shift ;;
  esac
done

[[ -n "$target_query" ]] || tmux_skill_die 'target is required'
[[ "$seconds" =~ ^[0-9]+$ ]] || tmux_skill_die '--seconds must be an integer'
[[ "$lines" =~ ^[1-9][0-9]*$ ]] || tmux_skill_die '--lines must be a positive integer'

tmux_skill_require_tmux
pane_id="$(tmux_skill_resolve_pane "$target_query" "$session")" || tmux_skill_die "no pane found for target/title: $target_query"
[[ "$pane_id" != 'AMBIGUOUS' ]] || tmux_skill_die "pane target '$target_query' is ambiguous"

target="$(tmux display-message -p -t "$pane_id" '#{session_name}:#{window_index}.#{pane_index}')"
printf 'Following tmux pane %s (%s) for %ss\n' "$pane_id" "$target" "$seconds"

start="$(date +%s)"
deadline=$((start + seconds))
previous=''

while true; do
  current="$(tmux capture-pane -p -J -t "$pane_id" -S "-$lines")"
  if [[ "$current" != "$previous" ]]; then
    printf '%s\n' '--- output ---'
    printf '%s\n' "$current"
    previous="$current"
  fi

  now="$(date +%s)"
  if (( now >= deadline )); then
    break
  fi
  sleep "$interval"
done
