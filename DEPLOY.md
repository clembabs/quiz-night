# Deploying Quiz Night (Milestone 8)

Target: **Serverpod Cloud**: managed Postgres, HTTPS, logs and a CDN, with no Docker or servers to run.
Steps follow the official docs at <https://docs.serverpod.dev/cloud>.

> Deploying creates a live service on your account and may cost money (pick a plan at
> <https://serverpod.dev/cloud>). These steps are for you to run, or to ask Claude to run one by one.

## 1. One-time setup (you)

1. Create an account: <https://console.serverpod.cloud/auth/signup>
2. Sign in from the terminal (opens your browser):

   ```bash
   serverpod cloud auth login
   ```

   The first `serverpod cloud` command installs the Cloud CLI by itself; check it with `serverpod cloud version`.

## 2. Launch (first deploy)

Run from the server package:

```bash
cd quiz_night_server && serverpod cloud launch
```

What it does and what to answer:

| It asks / does | Answer / notes |
|---|---|
| "Open the browser and create a new Serverpod Cloud project?" | **Enter**. In the Console keep the database **enabled**, choose a plan, set the project ID (ours is `quiznight`), **Launch Project**. |
| Adds pre-deploy hooks | `serverpod generate` and `serverpod run flutter_build` (our server's script builds the Flutter web app into `web/app`). Nothing to do. |
| "Which passwords to copy?" from `config/passwords.yaml` | **Copy none.** Cloud generates its own database credentials, service secret and auth (JWT) keys. The one custom secret, `geminiApiKey`, is set separately (step 2a). |
| Writes `scloud.yaml`, uploads, builds, rolls out | Wait for the 🚀 on *Rollout*. Commit `scloud.yaml` (it holds no secrets). |

Your URLs (for our project ID `quiznight`):

- **Play / QR target:** `https://quiznight.serverpod.space/`
- API: `https://quiznight.api.serverpod.space/` (the app finds it automatically via `/assets/assets/config.json`)
- Insights: `https://quiznight.insights.serverpod.space/`

## 2a. The Gemini key (AI-written questions)

Without it the game still works, with the built-in questions only. Add it once:

- **Console:** project → **Env & Passwords** → **Add password**, name `geminiApiKey`, paste the key; or
- **Terminal:** put the key in a temporary file, then

  ```bash
  cd quiz_night_server && serverpod cloud password set geminiApiKey --from-file key.txt
  ```

  and delete `key.txt`. Never commit the key or paste it into chat.

The server picks it up on the next start; the host setup page then shows the topic box.

## 3. Redeploy after changes

After the one-time setup below, **merging into `main` deploys automatically** (`.github/workflows/deploy.yml`).
By hand, from this laptop:

```bash
cd quiz_night_server && serverpod cloud deploy
```

Every deploy clears the CDN; `index.html` is never cached, so phones pick up a new build on the next load.

## 3a. CI/CD (GitHub Actions)

```
feature branch ──PR──▶ develop ──PR──▶ main ──merge──▶ deploy to Serverpod Cloud ──▶ tag a release
                  CI runs          CI must pass        smoke-test the live site     vX.Y.Z + notes
```

- **CI** (`.github/workflows/ci.yml`) runs on every PR into `develop` or `main` and on pushes to `develop`:
  - `server`: formatting, generated code up to date, `dart analyze --fatal-infos`, server tests (embedded Postgres)
  - `app`: Flutter formatting, `flutter analyze`, `flutter test`
  - `web`: release web build, with the app code's gzipped size in the run summary (budget 1200 KB)
- **`main` is protected**: changes only through a PR, and `server`, `app` and `web` must pass on an
  up-to-date branch. No force pushes or deletion.
- **Deploy** (`.github/workflows/deploy.yml`) runs on every push to `main`, or by hand from the Actions tab
  (run it on an older commit to roll back). It re-runs CI, deploys with `serverpod cloud deploy`, then
  checks that `/`, `/faq` and the app config respond on the live site.
- **Release**: after a successful deploy from a merge, the `release` job tags the commit and publishes a
  GitHub Release with notes grouped into Features, Fixes and Maintenance
  (`.github/scripts/next_release.sh`). The version follows the Conventional Commits since the last tag:

  | Commits since the last tag | Before 1.0 | From 1.0 |
  |---|---|---|
  | a breaking change (`feat!:`, or `BREAKING CHANGE:` in the body) | minor | major |
  | a `feat` | minor | minor |
  | only `fix`, `refactor`, `docs`, `ci`… | patch | patch |

  A manual run (a rollback) makes no release. Releases: <https://github.com/clembabs/quiz-night/releases>.

**One-time setup (you), after the first `make deploy-launch`:**

1. Commit `quiz_night_server/scloud.yaml` (written by the launch; no secrets in it).
2. Create a token for GitHub (an expiry is a good idea):

   ```bash
   serverpod cloud auth create-token --expire-at 2027-06-30T00:00:00Z
   ```

3. In GitHub: **Settings → Environments → New environment** `production`, then add the secret
   `SERVERPOD_CLOUD_TOKEN` with that token. Don't paste it anywhere else.
4. **Settings → Secrets and variables → Actions → Variables**: add `SERVERPOD_CLOUD_PROJECT` with your
   project ID (ours is `quiznight`). Until it exists the deploy job is skipped, so merges before the launch
   don't fail. Optional: `SITE_URL` if you attach a custom domain.

## 4. What is already prepared in the code

- The server serves the built Flutter app at `/` (`FlutterRoute` in `lib/server.dart`), so the **QR, the app
  and the room code all live on one address**. The QR encodes `https://<your-domain>/join?code=4821` (old `/?code=` links redirect there).
- **CDN caching is on** for the web build: a day at the edge, one minute in the browser (Flutter's file names
  aren't content-hashed). That keeps first loads fast for judges on mobile data.
- **No source maps** are shipped; the instant HTML loading screen shows while the ~3 MB first load runs.
- Secrets stay out of git (`config/passwords.yaml`, `.env` are ignored).

## 5. The day before the demo (checklist)

- [ ] Deploy, open `https://quiznight.serverpod.space/` on the **laptop you'll present from**, click
      **Start hosting**, create a room.
- [ ] On your **phone, on mobile data (Wi-Fi off)**: scan the QR, join. Note the first-load time.
- [ ] Get 3–4 friends (or extra phones/tabs) in and play a full game: rounds, the cut, back a finalist,
      buzzer final, podium.
- [ ] Mid-question, **lock a phone for 20 s and unlock it**: it should rejoin and keep its answer.
- [ ] **Refresh a phone** mid-game: it should reopen straight into the room.
- [ ] Press **Back** on a phone mid-game: it should return to the game, not an empty join form.
- [ ] Open `https://quiznight.serverpod.space/faq` directly: the FAQ page should load (deep links work).
- [ ] Check the projector: the host screens are designed for 1920×1080 and scale to fit any size.
- [ ] Optional: attach a custom domain in the Console (TLS is automatic) and redeploy so the QR shows it.

## 6. If something goes wrong

- Logs: in the Console, or see <https://docs.serverpod.dev/cloud/concepts/logs>.
- A failed deploy: <https://docs.serverpod.dev/cloud/guides/recover-from-a-failed-deploy>.
- Root shows "Flutter web app not built": the `flutter_build` hook failed. Run
  `cd quiz_night_server && serverpod run flutter_build` locally to see why, fix, redeploy.
