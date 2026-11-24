Use the `init` skill (`shore-guard:init`) for a one-time repository setup.
If the full steps of that skill are not in your context, read ${CLAUDE_PLUGIN_ROOT}/skills/init/SKILL.md before doing anything else; do not proceed from this summary alone.
Run `shore-guard init --plan --json` and show the plan before changing anything.
Never proceed without the user's explicit worktree, current-branch, or manual-runbook choice.
Follow every remaining step and fallback in the skill.
Initialization ends by following discovery. For several codebases it evaluates all of them, records their choices in `.shore/architecture-manifest.json`, confirms one decision table, and applies the manifest once at the repository root. For a single codebase it summarizes the selected blueprint or short-lived proposal and asks whether to proceed. It then sets up generated rules and baselines and hands those rules over to the repository.
