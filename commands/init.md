Use the `init` skill (`shore-guard:init`) for an approval-first repository setup.
If the full steps of that skill are not in your context, read ${CLAUDE_PLUGIN_ROOT}/skills/init/SKILL.md before doing anything else; do not proceed from this summary alone.
Run `shore-guard init --plan --json` and show the plan before changing anything.
Never proceed without the user's explicit worktree, current-branch, or manual-runbook choice.
Follow every remaining step and fallback in the skill.
Initialization ends by following the discovery skill (`shore-guard:discovery`), running `shore-guard discover --json`, and asking before adopting the returned architecture policy proposal.
