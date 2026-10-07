# Migrating from guard-cli

The legacy `guard-cli` and `.shoreguard.json` format are deprecated. Run
`shore-guard init` in the repository root. Init detects the legacy file, writes the new
`.shore/guard.json`, and reports every translated, dropped, or unknown setting. It does
not delete the legacy file. If both files exist, init exits with code 6 and asks you to
choose; it never overwrites either file silently.

| Legacy setting | New setting | Treatment |
| --- | --- | --- |
| `ref` | `developBranch` | translated |
| `thresholds` | `thresholds` | translated |
| `timeoutMinutes` | `polling.timeoutMs` | translated |
| `pollSeconds` | `polling.initialDelayMs` and `polling.maxDelayMs` | translated |
| `repo` | — | dropped; repository connection is resolved by init |
| `apiUrl` | — | dropped; service location is CLI-owned |

Unknown keys are preserved in the migration report but are not written to the strict
new schema. Review the report, run `shore-guard doctor`, then remove the legacy file
after confirming the new configuration.

## v0 behavior parity

The new `check` and `verify` flows trigger remote health evaluation, poll it to a final
state, compare the candidate with its base, and return a gate-specific exit code.
`verify --json` additionally writes and returns the completion receipt. There is no
separate v0 command surface; automation should use these commands.
