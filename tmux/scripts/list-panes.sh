#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: list-panes.sh [options]

List tmux panes with stable ids, targets, titles, commands, and paths.

Options:
  -s, --session NAME       Session to inspect. Defaults to current session.
  -w, --window NAME        Filter by exact window name.
  -a, --all-sessions       List panes across all sessions.
  -h, --help               Show this help.
USAGE
}

die() {
  printf 'ERROR: %s\n' "$1" >&2
  exit 1
}

command -v tmux >/dev/null 2>&1 || die 'tmux was not found in PATH'

session=''
window=''
all_sessions=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -s|--session) session="${2-}"; shift 2 ;;
    -w|--window) window="${2-}"; shift 2 ;;
    -a|--all-sessions) all_sessions=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) die "unknown option: $1" ;;
  esac
done

if [[ "$all_sessions" == true && -n "$session" ]]; then
  die 'use either --all-sessions or --session, not both'
fi

target_args=(-a)
if [[ "$all_sessions" == false ]]; then
  if [[ -z "$session" ]]; then
    session="$(tmux display-message -p '#{session_name}' 2>/dev/null || true)"
  fi
  [[ -n "$session" ]] || die 'could not detect current tmux session. Run from inside tmux, pass --session, or use --all-sessions.'
  target_args=(-s -t "$session")
fi

printf 'TARGET\tPANE_ID\tWINDOW\tTITLE\tACTIVE\tCOMMAND\tPATH\n'
tmux list-panes "${target_args[@]}" -F '#{session_name}:#{window_index}.#{pane_index}|#{pane_id}|#{window_name}|#{pane_title}|#{pane_active}|#{pane_current_command}|#{pane_current_path}' |
  while IFS='|' read -r target pane_id window_name title active command path; do
    if [[ -n "$window" && "$window_name" != "$window" ]]; then
      continue
    fi
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$target" "$pane_id" "$window_name" "$title" "$active" "$command" "$path"
  done
