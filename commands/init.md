Use the `init` skill (`shore-guard:init`) for a one-time repository setup.
If the full steps of that skill are not in your context, read ${CLAUDE_PLUGIN_ROOT}/skills/init/SKILL.md before doing anything else; do not proceed from this summary alone.
Run `shore-guard init --plan --json` and show the plan before changing anything.
Never proceed without the user's explicit worktree, current-branch, or manual-runbook choice.
Follow every remaining step and fallback in the skill.
Initialization ends by following discovery, summarizing the selected blueprint or short-lived proposal, asking whether to proceed, setting up generated rules and baselines, and handing those rules over to the repository.
