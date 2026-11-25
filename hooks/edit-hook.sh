#!/bin/sh
# Claude Code PostToolUse hook, placed at .claude/plugins/shore-guard/hooks/edit-hook.sh.
input=$(cat)
if [ -f .shore/guard.json ] && grep -Eq '"on-save"[[:space:]]*:[[:space:]]*"declined"' .shore/guard.json; then
  exit 0
fi
if [ -f .shore/guard.json ] && grep -Eq '"tool"[[:space:]]*:[[:space:]]*"custom"' .shore/guard.json; then
  config_command=$(sed -n 's/.*"singleFileCommand"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' .shore/guard.json | sed -n '1p')
  file=$(printf '%s' "$input" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
  if [ -n "$config_command" ] && [ -f "$file" ]; then
    case "$file" in
      *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs|*.mts|*.cts)
        set -- $config_command
        "$@" "$file" >&2 || exit 2
        ;;
    esac
  fi
  exit 0
fi

if [ ! -f eslint.config.shore.mjs ] && ! grep -Eq '"tool"[[:space:]]*:[[:space:]]*"eslint"' .shore/guard.json 2>/dev/null; then
  exit 0
fi

if [ -x node_modules/.bin/shore-guard ]; then
  cli=node_modules/.bin/shore-guard
elif command -v shore-guard >/dev/null 2>&1; then
  cli=shore-guard
else
  printf '%s\n' 'Shore Guard edit validation requires the shore-guard CLI. Install project dependencies.' >&2
  exit 2
fi
printf '%s\n' "$input" | "$cli" guards edit >&2 || exit 2
