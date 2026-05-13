#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$script_dir/lib.sh"

usage() {
  cat <<'USAGE'
Usage: wait-for-text.sh --target target-or-title --pattern pattern [options]

Poll a tmux pane until text appears.

Options:
  -t, --target TARGET    Pane id, tmux target, or pane title. Required.
  -p, --pattern PATTERN  Regex pattern to look for. Required.
  -F, --fixed            Treat pattern as a fixed string.
  -s, --session NAME     Session to search for pane titles. Defaults to current session.
  -T, --timeout SECONDS  Timeout. Default: 30.
  -i, --interval SECS    Poll interval. Default: 0.5.
  -l, --lines N          History lines to inspect. Default: 1000.
  -h, --help             Show this help.
USAGE
}

target=''
pattern=''
grep_flag='-E'
session=''
timeout='30'
interval='0.5'
lines='1000'

while [[ $# -gt 0 ]]; do
  case "$1" in
    -t|--target) target="${2-}"; shift 2 ;;
    -p|--pattern) pattern="${2-}"; shift 2 ;;
    -F|--fixed) grep_flag='-F'; shift ;;
    -s|--session) session="${2-}"; shift 2 ;;
    -T|--timeout) timeout="${2-}"; shift 2 ;;
    -i|--interval) interval="${2-}"; shift 2 ;;
    -l|--lines) lines="${2-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) tmux_skill_die "unknown option: $1" ;;
  esac
done

[[ -n "$target" ]] || tmux_skill_die '--target is required'
[[ -n "$pattern" ]] || tmux_skill_die '--pattern is required'
tmux_skill_require_nonnegative_int "$timeout" '--timeout'
tmux_skill_require_positive_int "$lines" '--lines'
tmux_skill_require_tmux

if [[ -z "$session" ]]; then
  session="$(tmux_skill_current_session)"
fi

pane_id="$(tmux_skill_resolve_pane_or_die "$target" "$session")"

start_epoch="$(date +%s)"
deadline=$((start_epoch + timeout))
pane_text=''

while true; do
  pane_text="$(tmux_skill_capture_pane "$pane_id" "$lines" 2>/dev/null || true)"

  if printf '%s\n' "$pane_text" | grep "$grep_flag" -- "$pattern" >/dev/null 2>&1; then
    resolved_target="$(tmux_skill_pane_target "$pane_id")"
    printf 'Found pattern in tmux pane %s (%s)\n' "$pane_id" "$resolved_target"
    exit 0
  fi

  now="$(date +%s)"
  if (( now >= deadline )); then
    printf 'Timed out after %ss waiting for pattern: %s\n' "$timeout" "$pattern" >&2
    printf 'Last %s lines from %s:\n' "$lines" "$pane_id" >&2
    printf '%s\n' "$pane_text" >&2
    exit 1
  fi

  sleep "$interval"
done
