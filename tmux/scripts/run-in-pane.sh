#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$script_dir/lib.sh"

usage() {
  cat <<'USAGE'
Usage: run-in-pane.sh [--name label] [options] -- command [args...]

Run a long-lived command in a named tmux pane in the current session.

Options:
  -n, --name NAME       Pane title/label. Defaults to inferred project/package name.
  -s, --session NAME    Tmux session. Defaults to current session.
  -w, --window NAME     Server window prefix. Default: servers.
  -m, --max-panes N     Max panes per server window. Default: 4.
  -c, --cwd DIR         Working directory. Default: current directory.
  --current-window      Split the current tmux window instead of using server windows.
  --server-window       Use managed server windows. Default.
  --new-window NAME     Create a dedicated new window with this name.
  --wait-for PATTERN    Wait for text after starting.
  --wait-timeout N      Readiness timeout seconds. Default: 30.
  --port PORT           Refuse to start if PORT is already listening.
  --allow-port-conflict Start even when --port is already listening.
  -h, --help            Show this help.

Examples:
  run-in-pane.sh --name web --port 3000 --wait-for Local: -- npm run dev
  run-in-pane.sh --name api --cwd ../api -- pnpm dev
  run-in-pane.sh --current-window --name app -- pnpm dev
USAGE
}

name=''
session=''
window_prefix='servers'
max_panes='4'
cwd=''
placement='server-window'
new_window_name=''
wait_for=''
wait_timeout='30'
port=''
allow_port_conflict=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -n|--name) name="${2-}"; shift 2 ;;
    -s|--session) session="${2-}"; shift 2 ;;
    -w|--window) window_prefix="${2-}"; shift 2 ;;
    -m|--max-panes) max_panes="${2-}"; shift 2 ;;
    -c|--cwd) cwd="${2-}"; shift 2 ;;
    --current-window) placement='current-window'; shift ;;
    --server-window) placement='server-window'; shift ;;
    --new-window) new_window_name="${2-}"; placement='new-window'; shift 2 ;;
    --wait-for) wait_for="${2-}"; shift 2 ;;
    --wait-timeout) wait_timeout="${2-}"; shift 2 ;;
    --port) port="${2-}"; shift 2 ;;
    --allow-port-conflict) allow_port_conflict=true; shift ;;
    -h|--help) usage; exit 0 ;;
    --) shift; break ;;
    *) tmux_skill_die "unknown option: $1" ;;
  esac
done

[[ $# -gt 0 ]] || tmux_skill_die 'command is required after --'
tmux_skill_require_positive_int "$max_panes" '--max-panes'
tmux_skill_require_nonnegative_int "$wait_timeout" '--wait-timeout'
if [[ -n "$port" ]]; then
  [[ "$port" =~ ^[0-9]+$ ]] || tmux_skill_die '--port must be an integer'
fi

tmux_skill_require_tmux

if [[ -z "$session" ]]; then
  session="$(tmux_skill_current_session)"
fi
[[ -n "$session" ]] || tmux_skill_die 'could not detect current tmux session. Run from inside tmux or pass --session.'

if [[ -z "$cwd" ]]; then
  cwd="$PWD"
fi
[[ -d "$cwd" ]] || tmux_skill_die "working directory does not exist: $cwd"

if [[ -z "$name" ]]; then
  name="$(tmux_skill_infer_name "$cwd")"
fi

pane_name="$(tmux_skill_sanitize_name "$name")"
[[ -n "$pane_name" ]] || tmux_skill_die "pane name sanitized to empty: $name"

cmd_string="$(tmux_skill_shell_join "$@")"
display_command="$*"

if [[ -n "$port" && "$allow_port_conflict" == false ]]; then
  port_owner="$(tmux_skill_port_owner "$port")"
  if [[ -n "$port_owner" ]]; then
    printf 'Port %s is already listening; refusing to start another server.\n' "$port" >&2
    printf '%s\n' "$port_owner" >&2
    tmux_skill_die "port conflict on $port. Stop the existing process or pass --allow-port-conflict."
  fi
fi

if [[ "$placement" == 'current-window' ]]; then
  current_pane="$(tmux_skill_current_pane)"
  [[ -n "$current_pane" ]] || tmux_skill_die 'could not detect current tmux pane. Run from inside tmux or omit --current-window.'
  pane_id="$(tmux split-window -h -d -P -F '#{pane_id}' -t "$current_pane" -c "$cwd" "$cmd_string")"
  tmux select-layout -t "$(tmux display-message -p -t "$pane_id" '#{window_id}')" even-horizontal >/dev/null 2>&1 || true
elif [[ "$placement" == 'new-window' ]]; then
  [[ -n "$new_window_name" ]] || tmux_skill_die '--new-window requires a window name'
  pane_id="$(tmux new-window -d -P -F '#{pane_id}' -t "$session:" -n "$new_window_name" -c "$cwd" "$cmd_string")"
else
  IFS='|' read -r choice target_window_id target_window_name < <(tmux_skill_server_window_choice "$session" "$window_prefix" "$max_panes")
  if [[ "$choice" == 'new' ]]; then
    pane_id="$(tmux new-window -d -P -F '#{pane_id}' -t "$session:" -n "$target_window_name" -c "$cwd" "$cmd_string")"
  else
    pane_id="$(tmux split-window -h -d -P -F '#{pane_id}' -t "$target_window_id" -c "$cwd" "$cmd_string")"
    tmux select-layout -t "$target_window_id" even-horizontal >/dev/null 2>&1 || true
  fi
fi

tmux select-pane -t "$pane_id" -T "$pane_name"

target="$(tmux_skill_pane_target "$pane_id")"
window_name="$(tmux_skill_pane_window "$pane_id")"
pane_command="$(tmux_skill_pane_command "$pane_id")"

tmux_skill_registry_upsert "$pane_name" "$pane_id" "$target" "$session" "$window_name" "$pane_name" "$cwd" "$cmd_string" "$placement"

cat <<EOF
Started tmux pane
TMUX_SESSION=$session
TMUX_WINDOW=$window_name
TMUX_PANE_ID=$pane_id
TMUX_TARGET=$target
TMUX_PANE_TITLE=$pane_name
TMUX_PANE_COMMAND=$pane_command
TMUX_COMMAND=$display_command
TMUX_CWD=$cwd
TMUX_PLACEMENT=$placement
TMUX_REGISTRY=$(tmux_skill_registry_path)
ATTACH_COMMAND=tmux attach -t '$session'
CAPTURE_COMMAND=tmux capture-pane -p -J -t '$pane_id' -S -120
LIST_COMMAND=tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index} #{pane_id} #{window_name} #{pane_title} #{pane_current_command}'
EOF

if [[ -n "$wait_for" ]]; then
  "$script_dir/wait-for-text.sh" --target "$pane_id" --fixed --pattern "$wait_for" --timeout "$wait_timeout"
fi
