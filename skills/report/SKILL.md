---
name: report
description: Author and file a Shore Guard setup feedback report with the user's consent.
---
# Guided feedback reporting

## 0. Follow the safety rules

Never include secrets, customer names, code, or file contents in a report. Never file a report without the repository's recorded consent. `shore-guard <command> --help` is safe to run. If `shore-guard` is not on PATH, use `node "${CLAUDE_PLUGIN_ROOT}/bin/shore-guard"` for every command below. If the CLI is missing entirely, ask the user to run `npx shore-guard setup` in a terminal, or `npm install -g shore-guard`.

Apply the `completion-contract` skill (`shore-guard:completion-contract`) exit-code table to every CLI result unless a section below gives more specific handling. Stop on every nonzero exit after giving its remediation. Never describe a queued report as filed successfully.

Manual:
`shore-guard <command> --help`

## 1. Author the report

List out a detailed report of anything that had issues or did not get hand-fed to you during the plugin init/discovery setup.

Include:

- commands that failed or needed retries;
- questions the user had to answer that the tool should have inferred;
- tools, languages, frameworks, or repository shapes reported unsupported;
- steps done manually;
- confusing, missing, or contradictory instructions;
- workarounds;
- suggestions.

Write the report to `.shore/reports/draft-<stage>.json` with this template:

```json
{
  "stage": "<stage>",
  "outcome": "success|partial|failed",
  "toolchain": {
    "languages": [],
    "frameworks": [],
    "packageManager": "",
    "repoShape": "single|monorepo",
    "lint": "",
    "test": ""
  },
  "durationMs": 0,
  "agent": {
    "name": "<agent name>",
    "model": "<model>"
  },
  "items": [
    {
      "kind": "issue|gap|manual-intervention|unsupported|suggestion",
      "summary": "<≤200 chars>",
      "detail": "<≤4000 chars>",
      "evidence": ["<repo-relative path or command>"]
    }
  ]
}
```

Use repository-relative paths only. Include no file contents, secrets, or customer names. Include at most 50 items. If nothing went wrong, still produce a `success` report with zero items.

Manual:
Write `.shore/reports/draft-<stage>.json` and review it against the privacy rules.

## 2. Consent (once per repository)

If `.shore/guard.json` has no `feedbackReports`, explain that the report sends the stage, plugin and CLI versions, generalized toolchain, outcome, and issue list. It sends no code, file contents, or secrets. Ask exactly one question with exactly these options:

(a) Send setup reports to Shore so we can fix gaps (recommended)

(b) Ask me each time

(c) Never for this repository

Record the answer with `shore-guard report submit --set-consent always --json`, `shore-guard report submit --set-consent ask --json`, or `shore-guard report submit --set-consent never --json`.

For `always`, file reports without asking again. For `ask`, show the full draft and ask exactly `Send this report? (yes/no)` each time; when the draft has zero items, skip that question and do not send. For `never`, stop silently.

Manual:
`shore-guard report submit --set-consent always|ask|never --json`

## 3. File

Run `shore-guard report submit --stage <stage> --file .shore/reports/draft-<stage>.json --json`. On exit 0 with `data.id`, relay the id. When exit 0 says `reports disabled for this repository`, stop silently.

On exit 4, say the report was queued and will be sent by the next `shore-guard report submit --pending`. On exit 3, tell the user to run `shore-guard login` or escalate, as required by the completion contract. On exit 2, fix the listed items and retry once. For any other nonzero exit, apply the completion-contract table and stop with its remediation.

Manual:
`shore-guard report submit --stage <stage> --file .shore/reports/draft-<stage>.json --json`

## 4. Finish

Thank the user and note that the report helps make Shore Guard work on more stacks.

Manual:
Review the filing result and relay its final status.
