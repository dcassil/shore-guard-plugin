#!/bin/sh
# Claude Code PostToolUse hook, placed at .claude/plugins/shore-guard/hooks/edit-hook.sh.
# Plumbing ported from dev-genie/guardrails/scripts/lint-edited-file.sh.
# TODO(SCRUM-55): plug Shore Guard edit-gate rule content into this seam.
input=$(cat)
file=$(printf '%s' "$input" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
[ -n "$file" ] || exit 0
[ -e "$file" ] || exit 0
case "$file" in *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs) ;; *) exit 0 ;; esac
if [ -n "${SHORE_GUARD_ESLINT_BIN:-}" ]; then lint=$SHORE_GUARD_ESLINT_BIN
elif [ -x node_modules/.bin/eslint_d ]; then lint=node_modules/.bin/eslint_d
elif [ -x node_modules/.bin/eslint ]; then lint=node_modules/.bin/eslint
else exit 0
fi
"$lint" --max-warnings=0 --cache --cache-location .eslintcache "$file" >&2 || exit 2
