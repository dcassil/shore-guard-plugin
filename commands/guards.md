Use the `guards` skill (`shore-guard:guards`) to install and configure rule engines from a selected blueprint or discovery proposal.
If the full steps of that skill are not in your context, read ${CLAUDE_PLUGIN_ROOT}/skills/guards/SKILL.md before doing anything else; do not proceed from this summary alone.
Run `shore-guard guards plan --blueprint <id> --json` or `shore-guard guards plan --source <proposalPath> --json`, present the complete plan, and ask exactly one choice before changing anything.
Follow every apply, drift, failure, and reporting rule in the skill.
A failed apply is resumed by fixing the cause and rerunning the same command; completed steps are kept.
Setting up meaningful on-save checking for the repository's language and framework is part of this skill.
After setup, make clear that the rules belong to the repository and Shore Guard will not change them again.
