#!/usr/bin/env bash

tmux_skill_die() {
  printf 'ERROR: %s\n' "$1" >&2
  exit 1
}

tmux_skill_require_tmux() {
  command -v tmux >/dev/null 2>&1 || tmux_skill_die 'tmux was not found in PATH'
}

tmux_skill_registry_path() {
  printf '%s\n' "${OPENCODE_TMUX_REGISTRY:-${TMPDIR:-/tmp}/opencode-tmux-panes.tsv}"
}

tmux_skill_sanitize_name() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | tr -cs '[:alnum:]_-' '-' | sed 's/^-//; s/-$//'
}

tmux_skill_clean_field() {
  printf '%s' "$1" | tr '\t\n\r' '   '
}

tmux_skill_current_session() {
  tmux display-message -p '#{session_name}' 2>/dev/null || true
}

tmux_skill_current_pane() {
  tmux display-message -p '#{pane_id}' 2>/dev/null || true
}

tmux_skill_require_positive_int() {
  local value="$1" name="$2"
  [[ "$value" =~ ^[1-9][0-9]*$ ]] || tmux_skill_die "$name must be a positive integer"
}

tmux_skill_require_nonnegative_int() {
  local value="$1" name="$2"
  [[ "$value" =~ ^[0-9]+$ ]] || tmux_skill_die "$name must be an integer number of seconds"
}

tmux_skill_shell_join() {
  local quoted=''
  printf -v quoted '%q ' "$@"
  printf '%s\n' "${quoted% }"
}

tmux_skill_infer_name() {
  local cwd="$1"
  local base parent
  base="$(basename "$cwd")"
  parent="$(basename "$(dirname "$cwd")")"

  if [[ "$parent" == 'packages' ]]; then
    printf '%s\n' "$(tmux_skill_sanitize_name "$base")"
    return
  fi

  case "$base" in
    app|api|web|worker|docs|storybook)
      printf '%s\n' "$base"
      ;;
    *)
      printf '%s\n' "$(tmux_skill_sanitize_name "$base")"
      ;;
  esac
}

tmux_skill_registry_ensure() {
  local registry dir
  registry="$(tmux_skill_registry_path)"
  dir="$(dirname "$registry")"
  mkdir -p "$dir"
  if [[ ! -f "$registry" ]]; then
    : > "$registry"
  fi
}

tmux_skill_registry_upsert() {
  local name="$1" pane_id="$2" target="$3" session="$4" window="$5" title="$6" cwd="$7" command="$8" placement="$9"
  local registry tmp now
  registry="$(tmux_skill_registry_path)"
  tmp="$(mktemp "${TMPDIR:-/tmp}/opencode-tmux-registry.XXXXXX")"
  now="$(date +%s)"
  tmux_skill_registry_ensure

  while IFS=$'\t' read -r r_name r_pane_id rest; do
    if [[ -z "${r_name:-}" ]]; then
      continue
    fi
    if [[ "$r_name" == "$name" || "$r_pane_id" == "$pane_id" ]]; then
      continue
    fi
    printf '%s\t%s\t%s\n' "$r_name" "$r_pane_id" "$rest" >> "$tmp"
  done < "$registry"

  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$(tmux_skill_clean_field "$name")" \
    "$(tmux_skill_clean_field "$pane_id")" \
    "$(tmux_skill_clean_field "$target")" \
    "$(tmux_skill_clean_field "$session")" \
    "$(tmux_skill_clean_field "$window")" \
    "$(tmux_skill_clean_field "$title")" \
    "$(tmux_skill_clean_field "$cwd")" \
    "$(tmux_skill_clean_field "$command")" \
    "$(tmux_skill_clean_field "$placement")" \
    "$now" >> "$tmp"

  mv "$tmp" "$registry"
}

tmux_skill_registry_lookup_name() {
  local name="$1" registry
  registry="$(tmux_skill_registry_path)"
  [[ -f "$registry" ]] || return 1

  while IFS=$'\t' read -r r_name r_pane_id r_target r_session r_window r_title r_cwd r_command r_placement r_updated; do
    if [[ "$r_name" == "$name" ]]; then
      printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$r_name" "$r_pane_id" "$r_target" "$r_session" "$r_window" "$r_title" "$r_cwd" "$r_command" "$r_placement" "$r_updated"
      return 0
    fi
  done < "$registry"

  return 1
}

tmux_skill_registry_remove_pane() {
  local pane_id="$1" registry tmp
  registry="$(tmux_skill_registry_path)"
  [[ -f "$registry" ]] || return 0
  tmp="$(mktemp "${TMPDIR:-/tmp}/opencode-tmux-registry.XXXXXX")"

  while IFS=$'\t' read -r r_name r_pane_id rest; do
    if [[ -z "${r_name:-}" || "$r_pane_id" == "$pane_id" ]]; then
      continue
    fi
    printf '%s\t%s\t%s\n' "$r_name" "$r_pane_id" "$rest" >> "$tmp"
  done < "$registry"

  mv "$tmp" "$registry"
}

tmux_skill_pane_exists() {
  local pane_id="$1"
  local resolved
  resolved="$(tmux display-message -p -t "$pane_id" '#{pane_id}' 2>/dev/null || true)"
  [[ "$resolved" == "$pane_id" ]]
}

tmux_skill_resolve_pane() {
  local query="$1" session="${2-}"
  local query_lower list_args exact_matches partial_matches title_lower registry_line registry_pane registry_session

  if [[ "$query" == %* ]] && tmux_skill_pane_exists "$query"; then
    printf '%s\n' "$query"
    return 0
  fi

  if [[ "$query" == *:* ]] && tmux display-message -p -t "$query" '#{pane_id}' >/dev/null 2>&1; then
    tmux display-message -p -t "$query" '#{pane_id}'
    return 0
  fi

  if registry_line="$(tmux_skill_registry_lookup_name "$query" 2>/dev/null)"; then
    registry_pane="$(printf '%s' "$registry_line" | cut -f2)"
    registry_session="$(printf '%s' "$registry_line" | cut -f4)"
    if [[ -n "$session" && "$registry_session" != "$session" ]]; then
      registry_pane=''
    fi
    if [[ -n "$registry_pane" ]] && tmux_skill_pane_exists "$registry_pane"; then
      printf '%s\n' "$registry_pane"
      return 0
    fi
  fi

  query_lower="$(printf '%s' "$query" | tr '[:upper:]' '[:lower:]')"
  list_args=(-a)
  if [[ -n "$session" ]]; then
    list_args=(-s -t "$session")
  fi

  exact_matches=()
  partial_matches=()
  while IFS='|' read -r pane_id target title window_name command; do
    title_lower="$(printf '%s' "$title" | tr '[:upper:]' '[:lower:]')"
    if [[ "$title" == "$query" ]]; then
      exact_matches+=("$pane_id|$target|$title|$window_name|$command")
    elif [[ "$title_lower" == *"$query_lower"* ]]; then
      partial_matches+=("$pane_id|$target|$title|$window_name|$command")
    fi
  done < <(tmux list-panes "${list_args[@]}" -F '#{pane_id}|#{session_name}:#{window_index}.#{pane_index}|#{pane_title}|#{window_name}|#{pane_current_command}')

  if (( ${#exact_matches[@]} == 1 )); then
    printf '%s\n' "${exact_matches[0]%%|*}"
    return 0
  fi

  if (( ${#exact_matches[@]} > 1 )); then
    printf 'AMBIGUOUS\n'
    printf '%s\n' "${exact_matches[@]}" >&2
    return 2
  fi

  if (( ${#partial_matches[@]} == 1 )); then
    printf '%s\n' "${partial_matches[0]%%|*}"
    return 0
  fi

  if (( ${#partial_matches[@]} > 1 )); then
    printf 'AMBIGUOUS\n'
    printf '%s\n' "${partial_matches[@]}" >&2
    return 2
  fi

  return 1
}

tmux_skill_resolve_pane_or_die() {
  local query="$1" session="${2-}"
  local pane_id status

  if [[ -z "$query" ]]; then
    pane_id="$(tmux_skill_current_pane)"
    [[ -n "$pane_id" ]] || tmux_skill_die 'could not detect current tmux pane'
    printf '%s\n' "$pane_id"
    return 0
  fi

  if pane_id="$(tmux_skill_resolve_pane "$query" "$session")"; then
    :
  else
    status=$?
    if [[ "$pane_id" == 'AMBIGUOUS' || "$status" -eq 2 ]]; then
      tmux_skill_die "pane target '$query' is ambiguous. Use a pane id or exact title."
    fi
    tmux_skill_die "no pane found for target/title: $query"
  fi
  printf '%s\n' "$pane_id"
}

tmux_skill_pane_field() {
  local pane_id="$1" format="$2"
  tmux display-message -p -t "$pane_id" "$format"
}

tmux_skill_pane_target() {
  tmux_skill_pane_field "$1" '#{session_name}:#{window_index}.#{pane_index}'
}

tmux_skill_pane_window() {
  tmux_skill_pane_field "$1" '#{window_name}'
}

tmux_skill_pane_title() {
  tmux_skill_pane_field "$1" '#{pane_title}'
}

tmux_skill_pane_command() {
  tmux_skill_pane_field "$1" '#{pane_current_command}'
}

tmux_skill_capture_pane() {
  local pane_id="$1" lines="$2"
  tmux capture-pane -p -J -t "$pane_id" -S "-$lines"
}

tmux_skill_print_pane_header() {
  local pane_id="$1" lines="${2-120}"
  cat <<EOF
TMUX_PANE=$pane_id
TMUX_TARGET=$(tmux_skill_pane_target "$pane_id")
TMUX_WINDOW=$(tmux_skill_pane_window "$pane_id")
TMUX_PANE_TITLE=$(tmux_skill_pane_title "$pane_id")
TMUX_PANE_COMMAND=$(tmux_skill_pane_command "$pane_id")
CAPTURE_COMMAND=tmux capture-pane -p -J -t '$pane_id' -S -$lines
EOF
}

tmux_skill_server_window_choice() {
  local session="$1" window_prefix="$2" max_panes="$3"
  local window_id window_name pane_count next_name index

  while IFS='|' read -r window_id window_name pane_count; do
    case "$window_name" in
      "$window_prefix"|"$window_prefix"-[0-9]*)
        if (( pane_count < max_panes )); then
          printf 'existing|%s|%s\n' "$window_id" "$window_name"
          return 0
        fi
        ;;
    esac
  done < <(tmux list-windows -t "$session" -F '#{window_id}|#{window_name}|#{window_panes}')

  next_name="$window_prefix"
  if tmux list-windows -t "$session" -F '#{window_name}' | grep -Fx -- "$next_name" >/dev/null 2>&1; then
    index=2
    while tmux list-windows -t "$session" -F '#{window_name}' | grep -Fx -- "$window_prefix-$index" >/dev/null 2>&1; do
      index=$((index + 1))
    done
    next_name="$window_prefix-$index"
  fi

  printf 'new|%s|%s\n' "$next_name" "$next_name"
}

tmux_skill_port_owner() {
  local port="$1"
  if command -v lsof >/dev/null 2>&1; then
    lsof -nP -iTCP:"$port" -sTCP:LISTEN 2>/dev/null || true
  fi
}
