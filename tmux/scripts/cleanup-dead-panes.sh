#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$script_dir/lib.sh"

tmux_skill_require_tmux
registry="$(tmux_skill_registry_path)"
[[ -f "$registry" ]] || { printf 'REGISTRY=%s\nREMOVED=0\n' "$registry"; exit 0; }

tmp="$(mktemp "${TMPDIR:-/tmp}/opencode-tmux-registry.XXXXXX")"
removed=0

while IFS=$'\t' read -r name pane_id rest; do
  [[ -n "${name:-}" ]] || continue
  if tmux_skill_pane_exists "$pane_id"; then
    printf '%s\t%s\t%s\n' "$name" "$pane_id" "$rest" >> "$tmp"
  else
    removed=$((removed + 1))
  fi
done < "$registry"

mv "$tmp" "$registry"

printf 'REGISTRY=%s\nREMOVED=%s\n' "$registry" "$removed"
