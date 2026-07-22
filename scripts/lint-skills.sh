#!/usr/bin/env bash
# lint-skills.sh — mechanically enforce the coherence contract (see CLAUDE.md).
# Run from anywhere; exits non-zero on any violation.
set -u
cd "$(dirname "$0")/.."
FAIL=0
err() { echo "FAIL: $*"; FAIL=1; }

HARNESS_PROVIDED="deep-research simplify"   # provided by the Claude Code harness, not this repo
LOCAL_ONLY="hydra-sync"                     # machine-local linked repos, not cataloged

mapfile -t SKILLS < <(find skills -maxdepth 1 -mindepth 1 -type d -printf '%f\n' | sort)

in_list() { local x=$1; shift; local i; for i in "$@"; do [ "$i" = "$x" ] && return 0; done; return 1; }

# 1. Frontmatter name matches folder name
for s in "${SKILLS[@]}"; do
  f="skills/$s/SKILL.md"
  [ -f "$f" ] || { err "$s has no SKILL.md"; continue; }
  n=$(grep -m1 '^name:' "$f" | sed 's/^name:[[:space:]]*//')
  [ "$n" = "$s" ] || err "$s: frontmatter name '$n' != folder name"
done

# 2. Every skill has a README index entry
for s in "${SKILLS[@]}"; do
  in_list "$s" $LOCAL_ONLY && continue
  grep -q "skills/$s/SKILL.md" README.md || err "$s missing from README skill index"
done

# 3. Every skill is mentioned in the flows router
for s in "${SKILLS[@]}"; do
  [ "$s" = flows ] && continue
  in_list "$s" $LOCAL_ONLY && continue
  grep -qE "\`/?$s\`" skills/flows/SKILL.md || err "$s not mentioned in flows router"
done

# 4. No dangling skill references (slash-invocations and "`x` skill" / "see `x`" prose)
refs=$( { grep -rhoE '`/[a-z0-9][a-z0-9-]*`' AGENTS.md CLAUDE.md README.md skills/*/SKILL.md 2>/dev/null | tr -d '`/';
          grep -rhoE 'the `[a-z0-9][a-z0-9-]*` skill' AGENTS.md CLAUDE.md README.md skills/*/SKILL.md 2>/dev/null | sed 's/the `//;s/` skill//';
          grep -rhoE 'see `[a-z0-9][a-z0-9-]*`' AGENTS.md CLAUDE.md README.md skills/*/SKILL.md 2>/dev/null | sed 's/see `//;s/`//'; } | sort -u )
for r in $refs; do
  in_list "$r" "${SKILLS[@]}" && continue
  in_list "$r" $HARNESS_PROVIDED && continue
  in_list "$r" $LOCAL_ONLY && continue
  err "dangling skill reference: '$r' (no skills/$r/, not marked harness-provided)"
done

# 5. Master pipelines are user-invoked
for s in "${SKILLS[@]}"; do
  case "$s" in
    *-semi-auto)
      grep -q '^disable-model-invocation: true' "skills/$s/SKILL.md" || err "$s: master lacks disable-model-invocation: true" ;;
  esac
done

# 6. Every lock entry has a folder
if command -v jq >/dev/null; then
  for k in $(jq -r '.skills | keys[]' .skill-lock.json); do
    [ -d "skills/$k" ] || err "lock entry '$k' has no skills/$k folder"
  done
fi

if [ "$FAIL" -eq 0 ]; then
  echo "lint-skills: all checks passed (${#SKILLS[@]} skills)"
fi
exit "$FAIL"
