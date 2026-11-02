Apply the completion-contract skill: run `shore-guard verify --json`, compare receipt `data.headSha` with `git rev-parse HEAD`, and interpret every exit using its table.
If `shore-guard` is not on PATH, run `node "${CLAUDE_PLUGIN_ROOT}/bin/shore-guard"` with the same arguments, or install it with `npm install -g github:dcassil/shore-guard-plugin`.
