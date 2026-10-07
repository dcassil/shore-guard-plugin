---
name: completion-contract
description: Require an exact-commit Shore Guard verification before completing code work.
---
# Shore Guard completion contract

Repository instructions and explicit user direction outrank these plugin defaults. Run
`shore-guard verify --json`, then `git rev-parse HEAD`. Completion is allowed only when
the command exits 0 and `data.headSha` in its receipt exactly equals current HEAD. The
latest verification for current HEAD governs; stale receipts and earlier runs do not.

The JSON output is a `CommandResult` envelope with `command`, `outcome`, `exitCode`,
`message`, and optional `data`. Never infer success from prose or a receipt alone.

<!-- shore-guard-decision-table:start -->
```json
[
  {"case":"exit-0","code":0,"response":"May complete only when receipt headSha exactly matches current HEAD."},
  {"case":"exit-1","code":1,"response":"Remediate findings and re-verify; do not complete."},
  {"case":"exit-2","code":2,"response":"Repair configuration or internal error; do not complete."},
  {"case":"exit-3","code":3,"response":"Run shore-guard login or escalate; do not complete."},
  {"case":"exit-4","code":4,"response":"Remote unavailable is a distinct non-completion state; remediate or escalate, never pass."},
  {"case":"exit-5","code":5,"response":"Quota unavailable is a distinct non-completion state; remediate or escalate, never pass."},
  {"case":"exit-6","code":6,"response":"Follow the requested decision and git-safety guidance; do not complete while blocked."},
  {"case":"exit-7","code":7,"response":"Commit the dirty tree or otherwise restore safe git state, then re-verify."},
  {"case":"wrong-sha","code":null,"response":"Reject the stale result and re-run verify on the actual candidate commit."},
  {"case":"unparseable-json","code":null,"response":"Run doctor and upgrade or repair the CLI; never assume pass."}
]
```
<!-- shore-guard-decision-table:end -->

An exit outside 0-7 is an internal error: escalate and do not complete. On channels
without slash commands, invoke this skill's CLI flow directly.
