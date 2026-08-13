---
name: computer-use-linux
description: "Observe or control the local Linux desktop GUI via the computer-use-linux MCP server: inspect windows and accessibility trees, take screenshots, click, scroll, type, press keys. Use when a task needs real desktop interaction with a Linux GUI app."
author: agent-sh
license: MIT
platforms: [linux]
---

# computer-use-linux

One integration point: the **MCP server** `computer-use-linux` (registered in Claude Code and Codex, launched as `computer-use-linux mcp`). It exposes all observation *and* input tools: `doctor`, `get_app_state`, `list_apps`, `list_windows`, `focused_window`, `screenshot`, `click`, `drag`, `scroll`, `type_text`, `press_key`, `perform_action`, `set_value`, `activate_window`, `move_window`, `resize_window`, `setup_accessibility`, `setup_window_targeting`.

Desktop machines only (fedora, cachy). Headless machines (happy, chubbs) have no desktop to control.

## Procedure

1. Start with `get_app_state` (or `doctor` if things look broken). It reports readiness diagnostics.
2. Before targeted input, call `list_windows`/`focused_window` and verify the intended window by title, app id, pid, or wm class.
3. Prefer semantic targeting from `get_app_state` (element indices or role/name/text/states selectors) over raw coordinates. Use coordinates only when there's no useful accessibility tree.
4. For text, prefer `type_text` with an explicit target selector (`window_id`, `pid`, `app_id`, `wm_class`, `title`, `tty`, ...) over relying on current focus.
5. After mutating actions, re-check state (`get_app_state`, `focused_window`, or app-specific readback).
6. Desktop input is stateful, so never run tool calls against this server concurrently.

## If the MCP tools aren't available

The server binary doubles as a CLI for observation only (no input): `computer-use-linux state [APP]`, `screenshot`, `windows`, `apps`, `doctor`. Fix the MCP registration rather than working around it for long.

## Setup / troubleshooting

```bash
bun install -g @agent-sh/computer-use-linux   # installs the `computer-use-linux` binary
computer-use-linux doctor | jq .readiness
```

Ready means: `can_build_accessibility_tree`, `can_query_windows`, `can_send_development_input` all true, `blockers: []`. If not:

```bash
computer-use-linux setup                       # enables AT-SPI, input support
systemctl --user enable --now ydotoold         # per-user input daemon
computer-use-linux setup-window-targeting      # GNOME Wayland: shell extension for window queries
```

- On GNOME Wayland, log out/in after `setup-window-targeting` installs the shell extension.
- Already-running GTK/Qt/Electron apps need a restart after AT-SPI is first enabled.
- GNOME may show a one-time portal prompt on the first screenshot.

MCP registration (the server speaks standard stdio JSON-RPC, so no wrapper scripts):

```bash
# Claude Code
claude mcp add --scope user computer-use-linux ~/.bun/bin/computer-use-linux mcp
```

```toml
# ~/.codex/config.toml
[mcp_servers.computer-use-linux]
command = "/home/efox/.bun/bin/computer-use-linux"
args = ["mcp"]
```
