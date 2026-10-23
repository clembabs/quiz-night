#!/usr/bin/env bash
# Reports the web build's download sizes in the run summary and fails when
# the app code (main.dart.js, gzipped as servers send it) is over budget.
#
#   .github/scripts/web_size_budget.sh <build/web dir> [budget KB]
set -euo pipefail

dir="$1"
budget_kb="${2:-1200}"

gz_kb() { echo $(( $(gzip -9c "$1" | wc -c) / 1024 )); }
raw_kb() { echo $(( $(wc -c <"$1") / 1024 )); }

app_gz=$(gz_kb "$dir/main.dart.js")
fonts_kb=$(( $(cat "$dir"/assets/assets/fonts/*.ttf | wc -c) / 1024 ))

{
  echo "### Web download size"
  echo
  echo "| File | Raw | Gzipped |"
  echo "|---|---|---|"
  echo "| main.dart.js (app code) | $(raw_kb "$dir/main.dart.js") KB | ${app_gz} KB |"
  echo "| Bundled fonts | ${fonts_kb} KB | (already compressed) |"
  echo
  echo "Budget for the app code: ${budget_kb} KB gzipped. Flutter's engine (CanvasKit, about 2–3 MB) comes from Google's CDN and is not counted."
} >> "${GITHUB_STEP_SUMMARY:-/dev/stdout}"

if (( app_gz > budget_kb )); then
  echo "::error::main.dart.js is ${app_gz} KB gzipped, over the ${budget_kb} KB budget. Check for a new heavy package."
  exit 1
fi
echo "main.dart.js is ${app_gz} KB gzipped (budget ${budget_kb} KB)."
