#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$script_dir/lib.sh"

usage() {
  cat <<'USAGE'
Usage: stop-pane.sh target-or-title [options]

Gracefully stop a tmux pane by pane id, tmux target, exact title, or title substring.

Options:
  -s, --session NAME        Session to search. Defaults to current session.
  -g, --grace SECONDS       Seconds to wait after C-c. Default: 2.
  -k, --kill                Kill the pane after grace period if it still exists. Default: true.
  --no-kill                 Send C-c only; leave the pane if it remains.
  -h, --help                Show this help.
USAGE
}

target_query=''
session=''
grace='2'
kill_after=true

while [[ $# -gt 0 ]]; do
  case "$1" in
    -s|--session) session="${2-}"; shift 2 ;;
    -g|--grace) grace="${2-}"; shift 2 ;;
    -k|--kill) kill_after=true; shift ;;
    --no-kill) kill_after=false; shift ;;
    -h|--help) usage; exit 0 ;;
    -*) tmux_skill_die "unknown option: $1" ;;
    *)
      if [[ -z "$target_query" ]]; then
        target_query="$1"
        shift
      else
        tmux_skill_die "unexpected argument: $1"
      fi
      ;;
  esac
done

[[ -n "$target_query" ]] || tmux_skill_die 'target or pane title is required'
tmux_skill_require_nonnegative_int "$grace" '--grace'
tmux_skill_require_tmux

if [[ -z "$session" ]]; then
  session="$(tmux_skill_current_session)"
fi

pane_id="$(tmux_skill_resolve_pane_or_die "$target_query" "$session")"

if ! resolved_target="$(tmux display-message -p -t "$pane_id" '#{session_name}:#{window_index}.#{pane_index}' 2>/dev/null)"; then
  tmux_skill_registry_remove_pane "$pane_id"
  cat <<EOF
Stopped tmux pane
TMUX_PANE=$pane_id
TMUX_TARGET=unknown
TMUX_WINDOW=unknown
TMUX_PANE_TITLE=$target_query
TMUX_PANE_COMMAND=unknown
ACTION=pane was already gone before metadata could be read
EOF
  exit 0
fi

window_name="$(tmux_skill_pane_window "$pane_id")"
title="$(tmux_skill_pane_title "$pane_id")"
command="$(tmux_skill_pane_command "$pane_id")"

if ! tmux send-keys -t "$pane_id" C-c 2>/dev/null; then
  tmux_skill_registry_remove_pane "$pane_id"
  cat <<EOF
Stopped tmux pane
TMUX_PANE=$pane_id
TMUX_TARGET=$resolved_target
TMUX_WINDOW=$window_name
TMUX_PANE_TITLE=$title
TMUX_PANE_COMMAND=$command
ACTION=pane was already gone before C-c could be sent
EOF
  exit 0
fi

if (( grace > 0 )); then
  sleep "$grace"
fi

pane_exists=false
if tmux_skill_pane_exists "$pane_id"; then
  pane_exists=true
fi

action='sent C-c'
if [[ "$pane_exists" == true && "$kill_after" == true ]]; then
  if tmux kill-pane -t "$pane_id" 2>/dev/null; then
    action='sent C-c, then killed remaining pane'
  else
    action='sent C-c; pane exited before kill-pane'
  fi
elif [[ "$pane_exists" == false ]]; then
  action='sent C-c; pane exited'
fi

tmux_skill_registry_remove_pane "$pane_id"

cat <<EOF
Stopped tmux pane
TMUX_PANE=$pane_id
TMUX_TARGET=$resolved_target
TMUX_WINDOW=$window_name
TMUX_PANE_TITLE=$title
TMUX_PANE_COMMAND=$command
ACTION=$action
EOF
