#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$script_dir/lib.sh"

usage() {
  cat <<'USAGE'
Usage: restart-pane.sh name [options] [-- command [args...]]

Restart a managed pane using its registry command/cwd, or a replacement command.

Options:
  -c, --cwd DIR         Override working directory.
  --current-window      Restart in current window.
  --server-window       Restart in server window.
  --new-window NAME     Restart in a new dedicated window.
  --wait-for PATTERN    Wait for text after starting.
  --wait-timeout N      Readiness timeout seconds. Default: 30.
  --port PORT           Refuse to start if PORT is already listening.
  -h, --help            Show this help.
USAGE
}

name=''
cwd=''
placement_args=()
wait_args=()
port_args=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    -c|--cwd) cwd="${2-}"; shift 2 ;;
    --current-window|--server-window) placement_args+=("$1"); shift ;;
    --new-window) placement_args+=("$1" "${2-}"); shift 2 ;;
    --wait-for|--wait-timeout|--port) wait_args+=("$1" "${2-}"); shift 2 ;;
    -h|--help) usage; exit 0 ;;
    --) shift; break ;;
    -*) tmux_skill_die "unknown option: $1" ;;
    *)
      if [[ -z "$name" ]]; then
        name="$1"
        shift
      else
        tmux_skill_die "unexpected argument: $1"
      fi
      ;;
  esac
done

[[ -n "$name" ]] || tmux_skill_die 'name is required'
name="$(tmux_skill_sanitize_name "$name")"

registry_line="$(tmux_skill_registry_lookup_name "$name" 2>/dev/null || true)"
[[ -n "$registry_line" || $# -gt 0 ]] || tmux_skill_die "no registry entry or replacement command for: $name"

old_pane=''
old_session=''
old_cwd=''
old_command=''
old_placement=''
if [[ -n "$registry_line" ]]; then
  old_pane="$(printf '%s' "$registry_line" | cut -f2)"
  old_session="$(printf '%s' "$registry_line" | cut -f4)"
  old_cwd="$(printf '%s' "$registry_line" | cut -f7)"
  old_command="$(printf '%s' "$registry_line" | cut -f8)"
  old_placement="$(printf '%s' "$registry_line" | cut -f9)"
fi

if [[ -n "$old_pane" ]] && tmux_skill_pane_exists "$old_pane"; then
  "$script_dir/stop-pane.sh" "$old_pane" --grace 2 >/dev/null || true
fi

if [[ -z "$cwd" ]]; then
  cwd="$old_cwd"
fi
[[ -n "$cwd" ]] || cwd="$PWD"

if [[ ${#placement_args[@]} -eq 0 ]]; then
  case "$old_placement" in
    current-window) placement_args=(--current-window) ;;
    new-window) placement_args=(--new-window "$name") ;;
    *) placement_args=(--server-window) ;;
  esac
fi

session_args=()
if [[ -n "$old_session" ]]; then
  session_args=(--session "$old_session")
fi

if [[ $# -gt 0 ]]; then
  "$script_dir/run-in-pane.sh" --name "$name" ${session_args[@]+"${session_args[@]}"} --cwd "$cwd" ${placement_args[@]+"${placement_args[@]}"} ${wait_args[@]+"${wait_args[@]}"} ${port_args[@]+"${port_args[@]}"} -- "$@"
else
  "$script_dir/run-in-pane.sh" --name "$name" ${session_args[@]+"${session_args[@]}"} --cwd "$cwd" ${placement_args[@]+"${placement_args[@]}"} ${wait_args[@]+"${wait_args[@]}"} ${port_args[@]+"${port_args[@]}"} -- bash -lc "$old_command"
fi
