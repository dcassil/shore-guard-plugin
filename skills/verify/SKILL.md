---
name: verify
description: Verify a candidate commit through the Shore Guard CLI.
---
Invoke the completion-contract skill (`shore-guard:completion-contract`), run `shore-guard verify --json`, and compare its receipt head SHA with `git rev-parse HEAD`. If required data is not exposed, extend the CLI rather than bypassing it.
If `shore-guard` is not on PATH, run `node "${CLAUDE_PLUGIN_ROOT}/bin/shore-guard"` with the same arguments, or install it with `npm install -g github:dcassil/shore-guard-plugin`.

When a failure cannot be remediated after applying the completion contract, follow the report skill (`shore-guard:report`) with stage `verify` and outcome `failed`. If the full steps of that skill are not in your context, read ${CLAUDE_PLUGIN_ROOT}/skills/report/SKILL.md before doing anything else; do not proceed from this summary alone. After the first successful verify, follow the report skill with stage `verify` and outcome `success`.
