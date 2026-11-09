Run `shore-guard login --json`. Interpret the CommandResult envelope and exit code using the completion-contract table. Do not bypass the CLI.
If `shore-guard` is not on PATH, run `node "${CLAUDE_PLUGIN_ROOT}/bin/shore-guard"` with the same arguments, or install it with `npm install -g github:dcassil/shore-guard-plugin`.
Never accept a pasted key in chat. Ask the user to run `shore-guard login` in their own terminal. CI uses `SHORE_API_KEY`.
