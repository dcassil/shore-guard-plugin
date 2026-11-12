---
name: login
description: Authenticate through the Shore Guard CLI.
---
Browser login is the default. Ask the user to run `shore-guard login` in their own terminal and approve the request in the browser. If you run the command for them, use `shore-guard login --no-browser --json`, relay the URL and code printed to stderr, and wait for the user to approve it. Read the final CommandResult envelope and apply the `completion-contract` skill (`shore-guard:completion-contract`) exit-code table. If required data is not exposed, extend the CLI rather than bypassing it.
If `shore-guard` is not on PATH, run `node "${CLAUDE_PLUGIN_ROOT}/bin/shore-guard"` with the same arguments, or install it with `npm install -g github:dcassil/shore-guard-plugin`.
Never ask for, accept, or relay an API key in chat. CI uses `SHORE_API_KEY`.
