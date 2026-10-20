#!/usr/bin/env bash
# Runs Quiz Night locally but reachable from any phone, through two ngrok
# HTTPS tunnels: one for the web app (port 8082) and one for the API (8080).
#
# Usage (from quiz_night_server):
#   tool/start_with_ngrok.sh           # reuse the last web build
#   tool/start_with_ngrok.sh --build   # rebuild the Flutter web app first
#
# Needs ngrok signed in once (`ngrok config add-authtoken <token>`).
set -euo pipefail

cd "$(dirname "$0")/.."

if [[ "${1:-}" == "--build" || ! -f web/app/index.html ]]; then
  echo "Building the Flutter web app into web/app…"
  serverpod run flutter_build
fi

# Your own ngrok config (holds the authtoken) plus the project's tunnels.
user_config="$(ngrok config check 2>/dev/null | sed -n 's/^Valid configuration file at //p')"
if [[ -z "$user_config" ]]; then
  echo "ngrok is not set up. Run: ngrok config add-authtoken <your-token>" >&2
  exit 1
fi

ngrok_log="${TMPDIR:-/tmp}/quiz-night-ngrok.log"
ngrok start --all --config "$user_config" --config tool/ngrok.yml \
  --log stdout --log-level warn >"$ngrok_log" 2>&1 &
ngrok_pid=$!
trap 'kill "$ngrok_pid" 2>/dev/null || true' EXIT

# Wait for both tunnels to report their public URLs. ngrok's local API is
# not up for the first moments, so a failed lookup must not end the script
# (set -e would otherwise stop it silently).
url_for() {
  curl -s -m 2 http://127.0.0.1:4040/api/tunnels 2>/dev/null |
    python3 -I -c "import sys,json; t={x['name']:x['public_url'] for x in json.load(sys.stdin)['tunnels']}; print(t.get('$1',''))" 2>/dev/null ||
    true
}
web_url=""; api_url=""
echo "Opening ngrok tunnels…"
for _ in $(seq 1 40); do
  if ! kill -0 "$ngrok_pid" 2>/dev/null; then
    echo "ngrok exited. Its log:" >&2
    cat "$ngrok_log" >&2
    exit 1
  fi
  web_url="$(url_for web)"; api_url="$(url_for api)"
  [[ -n "$web_url" && -n "$api_url" ]] && break
  sleep 0.5
done
if [[ -z "$web_url" || -z "$api_url" ]]; then
  echo "ngrok did not report both tunnels in 20 s. Its log:" >&2
  cat "$ngrok_log" >&2
  exit 1
fi

api_host="${api_url#https://}"
web_host="${web_url#https://}"

# The app reads its API address from /assets/assets/config.json, which the
# server builds from these; the lobby QR uses the page's own (ngrok) URL.
export SERVERPOD_API_SERVER_PUBLIC_HOST="$api_host"
export SERVERPOD_API_SERVER_PUBLIC_PORT=443
export SERVERPOD_API_SERVER_PUBLIC_SCHEME=https
export SERVERPOD_WEB_SERVER_PUBLIC_HOST="$web_host"
export SERVERPOD_WEB_SERVER_PUBLIC_PORT=443
export SERVERPOD_WEB_SERVER_PUBLIC_SCHEME=https

cat <<EOF

  Quiz Night is reachable from phones:
    Play / host:  $web_url
    API:          $api_url

  Open the Play link on the laptop, tap "Host a game", then scan the QR.
  First visit shows ngrok's "You are about to visit" page: tap Visit Site.
  Ctrl+C stops the server and closes the tunnels.

EOF

serverpod start
