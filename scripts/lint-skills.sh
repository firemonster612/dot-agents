#!/usr/bin/env bash
# lint-skills.sh — mechanically enforce the coherence contract (see CLAUDE.md).
# Run from anywhere; exits non-zero on any violation.
set -u
cd "$(dirname "$0")/.."
FAIL=0
err() { echo "FAIL: $*"; FAIL=1; }

HARNESS_PROVIDED=""                         # add names here when a reference appears
LOCAL_ONLY="hydra-sync"                     # machine-local linked repos, not cataloged
OPTIONAL="triage"                           # uninstalled skills referenced only behind an is-installed check
NOT_SKILLS="settings"                       # backticked slash-paths that are app routes in examples, not skill refs

mapfile -t SKILLS < <(find skills -maxdepth 1 -mindepth 1 -type d -printf '%f\n' | sort)

in_list() { local x=$1; shift; local i; for i in "$@"; do [ "$i" = "$x" ] && return 0; done; return 1; }

# 1. Frontmatter name matches folder name
for s in "${SKILLS[@]}"; do
  f="skills/$s/SKILL.md"
  [ -f "$f" ] || { err "$s has no SKILL.md"; continue; }
  n=$(awk 'NR == 1 && $0 == "---" { frontmatter = 1; next } frontmatter && $0 == "---" { exit } frontmatter && /^name:[[:space:]]*/ { sub(/^name:[[:space:]]*/, ""); print; exit }' "$f")
  [ "$n" = "$s" ] || err "$s: frontmatter name '$n' != folder name"
done

# 2b. Every README skill path resolves to an on-disk skill
for p in $(grep -oE 'skills/[a-z0-9-]+/SKILL\.md' README.md | sort -u); do
  [ -f "$p" ] || err "README index links nonexistent $p"
done

# 2. Every skill has a README index entry
for s in "${SKILLS[@]}"; do
  in_list "$s" $LOCAL_ONLY && continue
  grep -q "skills/$s/SKILL.md" README.md || err "$s missing from README skill index"
done

# 3. No dangling skill references (slash-invocations and "`x` skill" / "see `x`" prose)
refs=$( { grep -rhoE '`/[a-z0-9][a-z0-9-]*`' --include='*.md' AGENTS.md CLAUDE.md README.md skills/ 2>/dev/null | tr -d '`/';
          grep -rhoE 'the `[a-z0-9][a-z0-9-]*` skill' --include='*.md' AGENTS.md CLAUDE.md README.md skills/ 2>/dev/null | sed 's/the `//;s/` skill//';
          grep -rhoE 'see `[a-z0-9][a-z0-9-]*`' --include='*.md' AGENTS.md CLAUDE.md README.md skills/ 2>/dev/null | sed 's/see `//;s/`//'; } | sort -u )
for r in $refs; do
  in_list "$r" "${SKILLS[@]}" && continue
  in_list "$r" $HARNESS_PROVIDED && continue
  in_list "$r" $LOCAL_ONLY && continue
  in_list "$r" $OPTIONAL && continue
  in_list "$r" $NOT_SKILLS && continue
  err "dangling skill reference: '$r' (no skills/$r/, not marked harness-provided)"
done

# 4. Every lock entry has a folder
if ! command -v python3 >/dev/null 2>&1; then
  err "python3 required for lock check"
elif ! lock_keys=$(python3 -c 'import json; from pathlib import Path; data = json.loads(Path(".skill-lock.json").read_text()); skills = data["skills"]; assert isinstance(skills, dict); print("\n".join(skills))' 2>/dev/null); then
  err "invalid .skill-lock.json"
else
  for k in $lock_keys; do
    [ -d "skills/$k" ] || err "lock entry '$k' has no skills/$k folder"
  done
fi

if [ "$FAIL" -eq 0 ]; then
  echo "lint-skills: all checks passed (${#SKILLS[@]} skills)"
fi
exit "$FAIL"
