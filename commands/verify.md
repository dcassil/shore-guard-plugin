Apply the completion-contract skill (`shore-guard:completion-contract`): run `shore-guard verify --json`, compare receipt `data.headSha` with `git rev-parse HEAD`, and interpret every exit using its table.
If the full steps of that skill are not in your context, read ${CLAUDE_PLUGIN_ROOT}/skills/completion-contract/SKILL.md before doing anything else; do not proceed from this summary alone.
If `shore-guard` is not on PATH, run `node "${CLAUDE_PLUGIN_ROOT}/bin/shore-guard"` with the same arguments, or install it with `npm install -g github:dcassil/shore-guard-plugin`.
