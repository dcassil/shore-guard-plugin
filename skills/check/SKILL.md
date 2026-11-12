---
name: check
description: Check repository health through the Shore Guard CLI.
---
Run `shore-guard check --json`. Read the CommandResult envelope and apply the `completion-contract` skill (`shore-guard:completion-contract`) exit-code table. If required data is not exposed, extend the CLI rather than bypassing it.
If `shore-guard` is not on PATH, run `node "${CLAUDE_PLUGIN_ROOT}/bin/shore-guard"` with the same arguments, or install it with `npm install -g github:dcassil/shore-guard-plugin`.

When a failure cannot be remediated after applying the completion contract, follow the report skill (`shore-guard:report`) with stage `check` and outcome `failed`.
If the full steps of that skill are not in your context, read ${CLAUDE_PLUGIN_ROOT}/skills/report/SKILL.md before doing anything else; do not proceed from this summary alone.
