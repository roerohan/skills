---
name: tmux
description: Manage long-running commands in the user's current tmux session. Use when starting dev servers, watchers, background logs, or reading/interacting with named tmux panes.
---

# Tmux Skill

Use tmux for long-running or continuously logging commands. Do not run dev servers, file watchers, database consoles, or tailing logs directly inside the OpenCode shell unless the user explicitly asks for inline output. Put them in a tmux pane and read them from there.

## User Workflow

- One tmux session usually maps to one project or task area.
- Server processes belong in a window named `servers` by default.
- Multiple servers should be split into panes in that server window.
- Prefer side-by-side panes: use `tmux split-window -h`, then `tmux select-layout even-horizontal`. Do not use `tiled` immediately after a two-pane split because it may rearrange panes top/bottom.
- Keep at most 4 server panes per window. If all matching server windows are full, create `servers-2`, `servers-3`, etc.
- Name every pane with a short, stable label so the user can refer to it later.

## Required Agent Behavior

- Before starting a long-running command, say that it will run in tmux and name the intended pane/window.
- At the start of any tmux-managed workflow, use the permission preflight below if commands might be blocked. Ask/trigger permissions once up front instead of drip-feeding permission prompts like a haunted faucet.
- Use the helper scripts in this skill when possible. They handle naming, layout, and useful output. Less bespoke shell goblinry, more consistency.
- After creating or using a pane, report the exact session, window, pane id, and pane title.
- Always give the user copy/paste commands to attach and read logs.
- When the user refers to a pane by label, first list or resolve panes, then capture output from the matching pane.
- Prefer reading recent logs with `capture-pane`; summarize the important parts instead of dumping huge logs.
- If a pane label is ambiguous, ask one short clarification question with the matching panes.

## Permission Preflight

This skill commonly needs permission for tmux control and its helper scripts. Prefer these allow rules in `opencode/opencode.json` so normal use does not pause on every tmux operation:

```json
{
  "permission": {
    "bash": {
      "tmux *": "allow",
      "lsof *": "allow",
      "$HOME/.config/opencode/skills/*/scripts/*.sh *": "allow",
      "bash -n *opencode/skills/*/scripts/*.sh": "allow",
      "bash *opencode/skills/build-skill/scripts/validate_skill.sh *opencode/skills/tmux*": "allow"
    }
  }
}
```

If a command still asks for permission, request the broadest safe tmux-specific permission needed for the current workflow, not one tiny prompt at a time. Do not ask for unrestricted bash just to avoid thinking. Tempting, still lazy.

Commands this skill may run:

- `tmux list-sessions`, `tmux list-panes`, `tmux split-window`, `tmux new-window`, `tmux select-layout`, `tmux capture-pane`, `tmux send-keys`, `tmux kill-pane`, `tmux kill-session` for temp sessions it created.
- `run-in-pane.sh`, `run-or-reuse-pane.sh`, `restart-pane.sh`, `read-pane.sh`, `tail-pane.sh`, `wait-for-text.sh`, `send-to-pane.sh`, `stop-pane.sh`, `layout-window.sh`, `managed-panes.sh`, `cleanup-dead-panes.sh`.
- `lsof -nP -iTCP:<port> -sTCP:LISTEN` for port-conflict checks.

## Scripts

Run scripts from this skill directory, usually via absolute path:

```bash
opencode/skills/tmux/scripts/run-in-pane.sh --name api -- npm run dev
opencode/skills/tmux/scripts/run-in-pane.sh --current-window --name api -- npm run dev
opencode/skills/tmux/scripts/run-or-reuse-pane.sh --name api -- pnpm dev
opencode/skills/tmux/scripts/restart-pane.sh api
opencode/skills/tmux/scripts/list-panes.sh
opencode/skills/tmux/scripts/layout-window.sh --side-by-side
opencode/skills/tmux/scripts/managed-panes.sh
opencode/skills/tmux/scripts/read-pane.sh api --lines 120
opencode/skills/tmux/scripts/tail-pane.sh api --seconds 20
opencode/skills/tmux/scripts/send-to-pane.sh api -- ctrl-c
opencode/skills/tmux/scripts/wait-for-text.sh --target api --pattern 'ready' --timeout 30
opencode/skills/tmux/scripts/stop-pane.sh api
opencode/skills/tmux/scripts/cleanup-dead-panes.sh
```

## Starting Servers

Use `run-in-pane.sh` for dev servers and watchers:

```bash
opencode/skills/tmux/scripts/run-in-pane.sh --name web -- npm run dev
opencode/skills/tmux/scripts/run-in-pane.sh --name api -- pnpm dev
opencode/skills/tmux/scripts/run-in-pane.sh --name worker -- npm run worker
opencode/skills/tmux/scripts/run-in-pane.sh --current-window --name web -- npm run dev
opencode/skills/tmux/scripts/run-in-pane.sh --name web --port 3000 --wait-for 'Local:' -- npm run dev
```

Defaults:

- Session: current tmux session.
- Window prefix: `servers`.
- Max panes per server window: `4`.
- Pane title: value passed to `--name`, or an inferred project/package name when omitted.
- Working directory: current shell directory unless `--cwd` is provided.
- Pass `--current-window` when the user asks to run next to the current OpenCode pane instead of in the `servers` window.
- Pass `--server-window` to force the managed `servers` window workflow.
- Pass `--new-window NAME` to create a dedicated window.
- Pass `--wait-for PATTERN --wait-timeout N` to wait for readiness in the same operation.
- Pass `--port PORT` to refuse startup when a port is already listening. Use `--allow-port-conflict` only when the user explicitly wants that. Port fights are not a debugging strategy.

The script prints `TMUX_SESSION`, `TMUX_WINDOW`, `TMUX_PANE_ID`, `TMUX_TARGET`, attach commands, and capture commands. Include those in your response.

## Reusing And Restarting

Use `run-or-reuse-pane.sh` when starting a named server that might already exist:

```bash
opencode/skills/tmux/scripts/run-or-reuse-pane.sh --name web --port 3000 --wait-for 'Local:' -- npm run dev
opencode/skills/tmux/scripts/run-or-reuse-pane.sh --current-window --name app -- pnpm dev:app
```

Behavior:

- If a pane with that name is running, it reads recent logs instead of duplicating the server.
- If `--replace` is passed and cwd/command differs, it stops the old pane and starts a new one.
- If the pane is missing, it delegates to `run-in-pane.sh`.

Use `restart-pane.sh` when the user asks to restart a known pane:

```bash
opencode/skills/tmux/scripts/restart-pane.sh web --wait-for 'Local:'
opencode/skills/tmux/scripts/restart-pane.sh app --current-window -- pnpm dev:app
```

It uses the registry command/cwd when no replacement command is provided.

## Managed Registry

Managed panes are recorded in `${OPENCODE_TMUX_REGISTRY:-${TMPDIR:-/tmp}/opencode-tmux-panes.tsv}`.

Use these helpers:

```bash
opencode/skills/tmux/scripts/managed-panes.sh
opencode/skills/tmux/scripts/managed-panes.sh --all
opencode/skills/tmux/scripts/cleanup-dead-panes.sh
```

The registry tracks pane name, pane id, target, session, window, cwd, command, placement, and update time. Use it to avoid duplicate servers and to restart panes reliably.

## Reading Logs

Use `read-pane.sh`:

```bash
opencode/skills/tmux/scripts/read-pane.sh api --lines 200
opencode/skills/tmux/scripts/read-pane.sh %12 --lines 80
opencode/skills/tmux/scripts/read-pane.sh servers:1.2 --lines 120
```

Target resolution order:

- Exact pane id like `%12`.
- Exact tmux target like `session:window.pane`.
- Exact pane title.
- Case-insensitive pane title substring.
- Current pane if no target is provided.

Use `--raw` only when the user asks for raw logs. Otherwise summarize.

## Listing Panes

Use `list-panes.sh` when the user asks what is running, or when a label is unclear:

```bash
opencode/skills/tmux/scripts/list-panes.sh
opencode/skills/tmux/scripts/list-panes.sh --all-sessions
opencode/skills/tmux/scripts/list-panes.sh --window servers
```

It prints pane id, target, title, command, active state, and current path.

## Layout Windows

Use `layout-window.sh` whenever panes should be arranged or repaired after a split:

```bash
opencode/skills/tmux/scripts/layout-window.sh --side-by-side
opencode/skills/tmux/scripts/layout-window.sh --side-by-side --target 0:6
opencode/skills/tmux/scripts/layout-window.sh --stacked --target servers
```

Defaults:

- Target: current tmux window.
- `--side-by-side`: applies `even-horizontal` so panes sit left/right.
- `--stacked`: applies `even-vertical` so panes sit top/bottom.
- Prints the target window and pane list after applying the layout.

When the user asks for side-by-side or says a split is wrong, use this helper instead of raw `tmux select-layout`.

## Waiting For Output

Use `wait-for-text.sh` after starting a server if you need to wait for readiness:

```bash
opencode/skills/tmux/scripts/wait-for-text.sh --target web --pattern 'Local:' --timeout 30
opencode/skills/tmux/scripts/wait-for-text.sh --target api --fixed --pattern 'ready' --timeout 45
```

Do not spin forever. If readiness text does not appear, capture recent logs and explain what is visible.

## Following Logs

Use `tail-pane.sh` for short bounded monitoring after a command or file change:

```bash
opencode/skills/tmux/scripts/tail-pane.sh web --seconds 20 --lines 100
```

Never run unbounded tails. Bounded logs good; infinite scroll hypnosis bad.

## Sending Input

Use `send-to-pane.sh` instead of raw `tmux send-keys`:

```bash
opencode/skills/tmux/scripts/send-to-pane.sh web -- ctrl-c
opencode/skills/tmux/scripts/send-to-pane.sh web --literal rs --enter
opencode/skills/tmux/scripts/send-to-pane.sh web -- h enter
```

It resolves pane ids, tmux targets, pane titles, and managed registry names.

## Stopping Processes

Use `stop-pane.sh` for panes created or managed by this skill:

```bash
opencode/skills/tmux/scripts/stop-pane.sh api
opencode/skills/tmux/scripts/stop-pane.sh %12 --kill
```

Defaults:

- Resolves pane ids, tmux targets, exact pane titles, or title substrings.
- Sends `C-c` first for graceful shutdown.
- Kills the pane if it still exists after the grace period.
- Prints the stopped pane metadata.

Never kill unrelated panes. Tmux is not a piñata.

## Naming Rules

- Pane names should be short and semantic: `web`, `api`, `worker`, `db`, `docs`, `storybook`.
- If a command clearly belongs to a repo/package, include that only when useful: `web-admin`, `api-users`.
- Avoid spaces and punctuation in pane names. Use lowercase kebab-case.
- Window names should stay `servers`, `servers-2`, `servers-3` unless the user asks otherwise.

## User-Facing Message Template

After starting a command, say:

```text
Started `<command>` in tmux:
- Session: `<session>`
- Window: `<window>`
- Pane: `<pane-id>` / `<target>`
- Title: `<name>`

Attach: `tmux attach -t <session>`
Read logs: `tmux capture-pane -p -J -t '<pane-id>' -S -120`
```

If multiple server windows exist, mention the exact one. Precision: still fashionable.
