# Opencode Panel Project Notes

## Goal

Build a custom Neovim-first interface for OpenCode without depending on `opencode.nvim` internals.

The plugin should feel like part of this config, use `nui-components` like the search panel, and keep AI edits under Neovim control instead of letting an external plugin own the editing flow.

## Product Direction

- Use `opencode serve` as the backend.
- Build a scratch Lua client for HTTP and SSE.
- Build a floating chat panel with `nui-components`.
- Keep model selection, thinking strength, sessions, and edits inside this custom UI.
- Show AI work in the buffer with extmarks and virtual text.
- Apply edits through Neovim buffer APIs only.

## What Exists Now

### Existing plugin wiring

- The old `sudo-tee/opencode.nvim` plugin block has been commented out in `lua/plugins/AI.lua`.
- The new custom panel is loaded from `lua/plugins/config.lua` alongside the search panel setup.

### New modules

- `lua/opencode_panel/config.lua`
  - Default configuration.
  - Server host/port/startup timing.
  - UI sizing ratios.
  - Default agent selection.

- `lua/opencode_panel/state.lua`
  - Shared runtime state for panel renderer, signals, sessions, messages, models, variants, event jobs, and pending edits.

- `lua/opencode_panel/process.lua`
  - Starts `opencode serve` with a fixed host/port.
  - Probes server readiness.
  - Tracks whether the server was started by Neovim.
  - Stops the server on `VimLeavePre` if this plugin launched it.

- `lua/opencode_panel/client.lua`
  - Scratch HTTP client using `curl`.
  - Talks directly to the OpenCode server.
  - Supports:
    - session listing
    - session creation
    - message listing
    - message creation
    - session abort
    - provider/model lookup
    - SSE event subscription
  - Builds message payloads for prompt submission.

- `lua/opencode_panel/picker.lua`
  - Reusable custom picker built with `nui-components`.
  - Replaces `vim.ui.select` for panel workflows.
  - Used for sessions, models, variants, and pending edits.

- `lua/opencode_panel/edits.lua`
  - Parses `apply_patch` diffs into hunks.
  - Tracks hunks by file and by id.
  - Anchors pending hunks in buffers with extmarks.
  - Detects conflicts by comparing the current buffer region against the hunk's expected pre-edit lines.
  - Supports:
    - jump to next edit
    - jump to previous edit
    - jump to a specific edit id
    - accept current edit
    - reject current edit
    - list pending hunks for the edit picker

- `lua/opencode_panel/init.lua`
  - Main panel entry point.
  - Creates the floating chat UI.
  - Loads sessions and models.
  - Subscribes to OpenCode events.
  - Refreshes messages.
  - Updates header/status/transcript.
  - Connects panel actions to edit navigation and edit acceptance/rejection.

## Current UX

### Floating panel

The panel is a custom floating window built with `nui-components`.

It currently contains:

- header with session/model/thinking/agent/edit summary
- transcript area with conversation text and tool summaries
- prompt composer
- help line
- status line

### Custom pickers

These now open through the custom picker instead of default selectors:

- sessions
- models
- thinking strength / model variant
- pending edits browser

### Pending edits

When OpenCode emits patch tool output:

- the plugin extracts per-file diffs
- parses hunks
- shows pending AI edit markers in loaded buffers
- adds virtual text at the touched region
- marks conflicts if the current buffer no longer matches the expected old text

### Edit decisions

Current workflow:

- jump to a pending edit
- review the claimed region in the buffer
- accept the current hunk
- reject the current hunk

Acceptance applies the hunk through `nvim_buf_set_lines`.

No direct backend file write is used.

## Current Keymaps

Global keymaps defined in `lua/plugins/config.lua`:

- `<leader>aa` - toggle panel
- `<leader>as` - open session picker
- `<leader>am` - open model picker
- `<leader>at` - open thinking picker
- `<leader>an` - create new session
- `<leader>ae` - accept current AI edit
- `<leader>ad` - reject current AI edit
- `<leader>aj` - jump to next AI edit
- `<leader>ak` - jump to previous AI edit
- `<leader>al` - open pending AI edit list

Panel-local mappings:

- `<S-CR>` - send prompt
- `q` - close panel
- `r` - refresh messages
- `s` - session picker
- `m` - model picker
- `t` - thinking picker
- `n` - new session
- `c` - cancel active session
- `p` - pending edit picker
- `ge` - next edit
- `gE` - previous edit
- `ga` - accept current edit
- `gd` - reject current edit

## OpenCode Integration Details

The plugin currently assumes a local OpenCode server started with:

```sh
opencode serve --hostname 127.0.0.1 --port 41173
```

Main server endpoints currently used:

- `GET /session`
- `POST /session`
- `GET /session/:id/message`
- `POST /session/:id/message`
- `POST /session/:id/abort`
- `GET /config/providers`
- `GET /event`

## Validation Already Done

The work so far has been validated with headless Neovim and Lua syntax checks.

Verified flows:

- loading the panel module
- opening the panel in headless mode
- rendering the custom picker
- parsing a fake `apply_patch` response
- listing pending hunks
- jumping to a pending hunk
- accepting a pending hunk into a buffer

## Known Gaps

This is still the foundation, not the finished UX.

Important missing pieces:

- no inline live "claimed region while still thinking" markers yet
- no bulk accept/reject actions
- no dedicated edits pane inside the panel body
- no session creation form beyond quick creation
- no message composer history
- no permission/question response UI yet
- no richer markdown rendering yet
- no undo/redo model tied to accepted AI hunks
- no rebase flow for conflicted hunks
- no persistence for panel-local state across restarts

## Recommended Next Steps

### 1. Claimed regions before patch arrival

Goal:

- show that the AI is actively working on a specific region before the final patch lands

Ideas:

- listen more deeply to streaming event types
- create temporary extmarks for in-flight touched files/regions
- surface "thinking here" or "editing here" virtual text

### 2. Dedicated edits pane inside the panel

Goal:

- stop relying only on a popup browser for edits
- keep a permanent list of pending hunks visible in the main UI

Ideas:

- switch panel layout to multi-column or stacked sections
- conversation on one side, edits on the other
- selecting an edit in the panel should jump/focus the source buffer

### 3. Bulk workflows

Goal:

- make real editing sessions faster

Needed actions:

- accept all hunks in current file
- reject all hunks in current file
- accept all non-conflicting hunks
- reject all hunks for current session

### 4. Conflict workflow

Goal:

- handle overlaps between user edits and AI edits in a deliberate way

Needed behavior:

- richer conflict indicator
- preview before deciding
- optional diff view between expected old region and current region
- possibly "force apply" or "rebase hunk" later

### 5. Better session management

Goal:

- make resuming conversations feel smoother

Ideas:

- session rename
- session delete
- filter/search sessions
- fork session support
- show timestamps and model metadata more clearly

### 6. Better model and agent control

Goal:

- expose more of OpenCode's knobs in the custom UX

Ideas:

- picker for agent selection
- show current provider/model/variant in a compact status chip style
- preserve last-used model and variant per workspace

### 7. Rich transcript rendering

Goal:

- make the conversation easier to read when sessions get longer

Ideas:

- markdown rendering for message text
- better tool result formatting
- clearer grouping for user / assistant / tool / patch parts

## Suggested Recovery Checklist For Future Work

When coming back to this later:

1. open `lua/opencode_panel/init.lua`
2. review `lua/opencode_panel/edits.lua`
3. open `opencode-panel-status.md`
4. run a headless load test
5. start with either the edits pane or claimed-region streaming work

Useful manual checks:

```sh
nvim --headless "+lua require('opencode_panel').setup()" +qall
```

```sh
opencode serve --hostname 127.0.0.1 --port 41173
```

Then inside Neovim:

- open panel with `<leader>aa`
- resume or create session
- send prompt
- inspect edit markers
- accept/reject hunks

## Important Note About Git State

There is also an existing modification in `lazy-lock.json` that was already present in the working tree and is not part of this feature work unless intentionally staged later.
