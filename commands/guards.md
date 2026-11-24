Use the `guards` skill (`shore-guard:guards`) to install and configure rule engines from a selected blueprint or discovery proposal.
If the full steps of that skill are not in your context, read ${CLAUDE_PLUGIN_ROOT}/skills/guards/SKILL.md before doing anything else; do not proceed from this summary alone.
Run `shore-guard guards plan --blueprint <id> --json` or `shore-guard guards plan --source <proposalPath> --json` for a single codebase. For several codebases, run `shore-guard guards plan --manifest .shore/architecture-manifest.json --json`; one installation at the repository root covers them all. Apply with the matching `shore-guard guards apply --manifest .shore/architecture-manifest.json --json` option. Per-codebase manifest problems exit 2 with the codebase path and must be fixed in the manifest. A successful apply removes the manifest and its referenced proposals. Type checking still uses only the root `tsconfig.json`.
Follow every apply, drift, failure, and reporting rule in the skill.
A failed apply is resumed by fixing the cause and rerunning the same command; completed steps are kept.
Setting up meaningful on-save checking for the repository's language and framework is part of this skill.
After setup, make clear that the rules belong to the repository and Shore Guard will not change them again.
