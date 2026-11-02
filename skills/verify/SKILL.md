---
name: shore-guard-verify
description: Verify a candidate commit through the Shore Guard CLI.
---
Invoke the completion-contract skill, run `shore-guard verify --json`, and compare its receipt head SHA with `git rev-parse HEAD`. If required data is not exposed, extend the CLI rather than bypassing it.
If `shore-guard` is not on PATH, run `node "${CLAUDE_PLUGIN_ROOT}/bin/shore-guard"` with the same arguments, or install it with `npm install -g github:dcassil/shore-guard-plugin`.
