#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: layout-window.sh (--side-by-side|--stacked|--tiled) [options]

Apply a tmux layout to a window and print the resulting panes.

Options:
  --side-by-side       Arrange panes left/right with even-horizontal.
  --stacked            Arrange panes top/bottom with even-vertical.
  --tiled              Arrange panes using tmux tiled layout.
  -t, --target TARGET  Window target. Defaults to current window.
  -h, --help           Show this help.
USAGE
}

die() {
  printf 'ERROR: %s\n' "$1" >&2
  exit 1
}

command -v tmux >/dev/null 2>&1 || die 'tmux was not found in PATH'

target=''
layout=''
layout_name=''

while [[ $# -gt 0 ]]; do
  case "$1" in
    --side-by-side)
      layout='even-horizontal'
      layout_name='side-by-side'
      shift
      ;;
    --stacked)
      layout='even-vertical'
      layout_name='stacked'
      shift
      ;;
    --tiled)
      layout='tiled'
      layout_name='tiled'
      shift
      ;;
    -t|--target)
      target="${2-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "unknown option: $1"
      ;;
  esac
done

[[ -n "$layout" ]] || die 'choose one layout: --side-by-side, --stacked, or --tiled'

if [[ -z "$target" ]]; then
  target="$(tmux display-message -p '#{session_name}:#{window_index}' 2>/dev/null || true)"
fi
[[ -n "$target" ]] || die 'could not detect current tmux window. Run from inside tmux or pass --target.'

tmux select-layout -t "$target" "$layout" >/dev/null

resolved_window="$(tmux display-message -p -t "$target" '#{session_name}:#{window_index}')"
window_name="$(tmux display-message -p -t "$target" '#{window_name}')"

cat <<EOF
Applied tmux layout
TMUX_WINDOW_TARGET=$resolved_window
TMUX_WINDOW_NAME=$window_name
TMUX_LAYOUT=$layout_name
TMUX_LAYOUT_COMMAND=tmux select-layout -t '$resolved_window' $layout
--- panes ---
EOF

printf 'TARGET|PANE_ID|WINDOW|TITLE|ACTIVE|COMMAND|PATH\n'
tmux list-panes -t "$resolved_window" -F '#{session_name}:#{window_index}.#{pane_index}|#{pane_id}|#{window_name}|#{pane_title}|#{pane_active}|#{pane_current_command}|#{pane_current_path}'
