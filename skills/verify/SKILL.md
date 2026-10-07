---
name: shore-guard-verify
description: Verify a candidate commit through the Shore Guard CLI.
---
Invoke the completion-contract skill, run `shore-guard verify --json`, and compare its receipt head SHA with `git rev-parse HEAD`. If required data is not exposed, extend the CLI rather than bypassing it.
