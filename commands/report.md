Use the `report` skill (`shore-guard:report`) to author and file a structured setup feedback report with the user's consent.
If the full steps of that skill are not in your context, read ${CLAUDE_PLUGIN_ROOT}/skills/report/SKILL.md before doing anything else; do not proceed from this summary alone.
Write the draft for the requested stage, apply the repository's recorded consent choice, and run `shore-guard report submit --stage <stage> --file .shore/reports/draft-<stage>.json --json` when permitted.
Follow every privacy, consent, queue, failure, and reporting rule in the skill.
