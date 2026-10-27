#!/usr/bin/env bash
# Works out the next release from Conventional Commits since the last v* tag,
# prints its version (nothing when there is nothing to release, or the commit
# is already tagged) and writes its notes to a file.
#
#   .github/scripts/next_release.sh <commit> <notes file>
#
# Before 1.0, a feat or breaking change bumps the minor version; anything
# else bumps the patch. From 1.0, breaking changes bump the major.
set -euo pipefail

target="$1"
notes="$2"
repo_url="${GITHUB_SERVER_URL:-https://github.com}/${GITHUB_REPOSITORY:-clembabs/quiz-night}"

# A re-run, or a rollback deploy of an older commit: no second release.
if git tag --points-at "$target" | grep -q '^v[0-9]'; then
  exit 0
fi

last=$(git describe --tags --abbrev=0 --match 'v[0-9]*' "$target" 2>/dev/null || true)
range="${last:+$last..}$target"
log=$(git log --no-merges --format='%H%x09%s' "$range")
[ -z "$log" ] && exit 0

IFS=. read -r major minor patch <<<"${last#v}"
major=${major:-0} minor=${minor:-0} patch=${patch:-0}

subjects=$(cut -f2- <<<"$log")
breaking=false
if grep -qE '^[a-z]+(\([^)]*\))?!:' <<<"$subjects" ||
  git log --no-merges --format='%b' "$range" | grep -q '^BREAKING CHANGE'; then
  breaking=true
fi
feature=false
grep -qE '^feat(\([^)]*\))?!?:' <<<"$subjects" && feature=true

if $breaking && [ "$major" -gt 0 ]; then
  major=$((major + 1)) minor=0 patch=0
elif $breaking || $feature; then
  minor=$((minor + 1)) patch=0
else
  patch=$((patch + 1))
fi
version="v$major.$minor.$patch"

# "feat(server): add x" -> "**server:** add x (abc1234)", grouped by type.
section() {
  local title="$1" types="$2" lines
  lines=$(while IFS=$'\t' read -r sha subject; do
    if [[ "$subject" =~ ^($types)(\(([^\)]*)\))?!?:\ (.*)$ ]]; then
      scope="${BASH_REMATCH[3]}" text="${BASH_REMATCH[4]}"
      echo "- ${scope:+**$scope:** }$text (${sha:0:7})"
    fi
  done <<<"$log")
  if [ -n "$lines" ]; then
    printf '### %s\n\n%s\n\n' "$title" "$lines"
  fi
}

{
  $breaking && printf '> **This release has breaking changes.**\n\n'
  section 'Features' 'feat'
  section 'Fixes' 'fix'
  section 'Performance' 'perf'
  section 'Maintenance' 'refactor|test|docs|ci|build|chore|style'
  if [ -n "$last" ]; then
    echo "**Full changelog:** $repo_url/compare/$last...$version"
  fi
} >"$notes"

echo "$version"
