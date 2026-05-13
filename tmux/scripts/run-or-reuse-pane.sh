#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$script_dir/lib.sh"

usage() {
  cat <<'USAGE'
Usage: run-or-reuse-pane.sh [--name label] [options] -- command [args...]

Reuse an existing managed pane by name, or start it if missing.

Options mostly match run-in-pane.sh. Extra options:
  --replace       Stop and replace an existing pane if command/cwd differ.
  --read-lines N  Read this many lines when reusing. Default: 80.
  -h, --help      Show this help.
USAGE
}

name=''
cwd=''
replace=false
read_lines='80'
run_args=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    -n|--name) name="${2-}"; run_args+=("$1" "$2"); shift 2 ;;
    -c|--cwd) cwd="${2-}"; run_args+=("$1" "$2"); shift 2 ;;
    --replace) replace=true; shift ;;
    --read-lines) read_lines="${2-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    --) shift; break ;;
    *) run_args+=("$1"); shift ;;
  esac
done

[[ $# -gt 0 ]] || tmux_skill_die 'command is required after --'
tmux_skill_require_positive_int "$read_lines" '--read-lines'
if [[ -z "$cwd" ]]; then
  cwd="$PWD"
fi
if [[ -z "$name" ]]; then
  name="$(tmux_skill_infer_name "$cwd")"
  run_args=(--name "$name" "${run_args[@]}")
fi
name="$(tmux_skill_sanitize_name "$name")"

tmux_skill_require_tmux
pane_id=''
if pane_id="$(tmux_skill_resolve_pane "$name" "")"; then
  existing_cwd="$(tmux display-message -p -t "$pane_id" '#{pane_current_path}')"
  registry_line="$(tmux_skill_registry_lookup_name "$name" 2>/dev/null || true)"
  registry_command=''
  if [[ -n "$registry_line" ]]; then
    registry_command="$(printf '%s' "$registry_line" | cut -f8)"
  fi
  requested_command="$(tmux_skill_shell_join "$@")"

  if [[ "$replace" == true && ( "$existing_cwd" != "$cwd" || ( -n "$registry_command" && "$registry_command" != "$requested_command" ) ) ]]; then
    "$script_dir/stop-pane.sh" "$pane_id" --grace 2 >/dev/null || true
  else
    "$script_dir/read-pane.sh" "$pane_id" --lines "$read_lines"
    exit 0
  fi
fi

"$script_dir/run-in-pane.sh" "${run_args[@]}" -- "$@"
