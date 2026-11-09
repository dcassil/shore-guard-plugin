---
name: shore-guard-login
description: Authenticate through the Shore Guard CLI.
---
Run `shore-guard login --json`. Read the CommandResult envelope and apply the completion-contract exit-code table. If required data is not exposed, extend the CLI rather than bypassing it.
If `shore-guard` is not on PATH, run `node "${CLAUDE_PLUGIN_ROOT}/bin/shore-guard"` with the same arguments, or install it with `npm install -g github:dcassil/shore-guard-plugin`.
Never accept a pasted key in chat. Ask the user to run `shore-guard login` in their own terminal. CI uses `SHORE_API_KEY`.
