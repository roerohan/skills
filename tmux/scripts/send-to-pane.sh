#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$script_dir/lib.sh"

usage() {
  cat <<'USAGE'
Usage: send-to-pane.sh target [options] [-- key ...]

Safely send keys or literal text to a tmux pane.

Options:
  -s, --session NAME  Session to search for pane titles.
  -l, --literal TEXT  Send literal text.
  -e, --enter         Send Enter after literal text or keys.
  -h, --help          Show this help.

Examples:
  send-to-pane.sh web -- ctrl-c
  send-to-pane.sh web --literal rs --enter
  send-to-pane.sh web -- h enter
USAGE
}

target_query=''
session=''
literal=''
send_enter=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -s|--session) session="${2-}"; shift 2 ;;
    -l|--literal) literal="${2-}"; shift 2 ;;
    -e|--enter) send_enter=true; shift ;;
    -h|--help) usage; exit 0 ;;
    --) shift; break ;;
    -*) tmux_skill_die "unknown option: $1" ;;
    *)
      if [[ -z "$target_query" ]]; then
        target_query="$1"
        shift
      else
        break
      fi
      ;;
  esac
done

[[ -n "$target_query" ]] || tmux_skill_die 'target is required'
tmux_skill_require_tmux
pane_id="$(tmux_skill_resolve_pane "$target_query" "$session")" || tmux_skill_die "no pane found for target/title: $target_query"
[[ "$pane_id" != 'AMBIGUOUS' ]] || tmux_skill_die "pane target '$target_query' is ambiguous"

if [[ -n "$literal" ]]; then
  tmux send-keys -t "$pane_id" -l -- "$literal"
fi

if [[ $# -gt 0 ]]; then
  keys=()
  for key in "$@"; do
    case "$key" in
      ctrl-c|CTRL-C|c-c|C-c) keys+=(C-c) ;;
      ctrl-d|CTRL-D|c-d|C-d) keys+=(C-d) ;;
      ctrl-z|CTRL-Z|c-z|C-z) keys+=(C-z) ;;
      enter|Enter|ENTER) keys+=(Enter) ;;
      escape|Escape|ESC) keys+=(Escape) ;;
      *) keys+=("$key") ;;
    esac
  done
  tmux send-keys -t "$pane_id" -- "${keys[@]}"
fi

if [[ "$send_enter" == true ]]; then
  tmux send-keys -t "$pane_id" Enter
fi

target="$(tmux display-message -p -t "$pane_id" '#{session_name}:#{window_index}.#{pane_index}')"
title="$(tmux display-message -p -t "$pane_id" '#{pane_title}')"
printf 'Sent input to tmux pane\nTMUX_PANE=%s\nTMUX_TARGET=%s\nTMUX_PANE_TITLE=%s\n' "$pane_id" "$target" "$title"
