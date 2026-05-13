#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$script_dir/lib.sh"

usage() {
  cat <<'USAGE'
Usage: managed-panes.sh [--all]

List panes recorded by the OpenCode tmux skill registry.

Options:
  --all       Include stale/dead registry entries.
  -h, --help  Show this help.
USAGE
}

include_all=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --all) include_all=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) tmux_skill_die "unknown option: $1" ;;
  esac
done

tmux_skill_require_tmux
registry="$(tmux_skill_registry_path)"

printf 'REGISTRY=%s\n' "$registry"
printf 'NAME|PANE_ID|ALIVE|TARGET|SESSION|WINDOW|TITLE|PLACEMENT|UPDATED|CWD|COMMAND\n'

[[ -f "$registry" ]] || exit 0

while IFS=$'\t' read -r name pane_id target session window title cwd command placement updated; do
  [[ -n "${name:-}" ]] || continue
  alive='no'
  if tmux_skill_pane_exists "$pane_id"; then
    alive='yes'
  fi
  if [[ "$include_all" == false && "$alive" != 'yes' ]]; then
    continue
  fi
  printf '%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s\n' "$name" "$pane_id" "$alive" "$target" "$session" "$window" "$title" "$placement" "$updated" "$cwd" "$command"
done < "$registry"
