#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$script_dir/lib.sh"

usage() {
  cat <<'USAGE'
Usage: read-pane.sh [target-or-title] [options]

Capture recent output from a tmux pane. If no target is provided, reads current pane.

Options:
  -s, --session NAME    Session to search. Defaults to current session.
  -l, --lines N         History lines to capture. Default: 120.
  -r, --raw             Print only captured pane text.
  -h, --help            Show this help.

Targets can be pane ids (%12), tmux targets (session:1.2), exact pane titles,
or case-insensitive pane-title substrings.
USAGE
}

target_query=''
session=''
lines='120'
raw=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -s|--session) session="${2-}"; shift 2 ;;
    -l|--lines|--lines) lines="${2-}"; shift 2 ;;
    -r|--raw) raw=true; shift ;;
    -h|--help) usage; exit 0 ;;
    --) shift; break ;;
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

tmux_skill_require_positive_int "$lines" '--lines'
tmux_skill_require_tmux

if [[ -z "$session" ]]; then
  session="$(tmux_skill_current_session)"
fi

pane_id="$(tmux_skill_resolve_pane_or_die "$target_query" "$session")"

if [[ "$raw" == false ]]; then
  tmux_skill_print_pane_header "$pane_id" "$lines"
  printf '%s\n' '--- output ---'
fi

tmux_skill_capture_pane "$pane_id" "$lines"
