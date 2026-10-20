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
| "Open the browser and create a new Serverpod Cloud project?" | **Enter**. In the Console keep the database **enabled**, choose a plan, set the project ID (e.g. `quiz-night`), **Launch Project**. |
| Adds pre-deploy hooks | `serverpod generate` and `serverpod run flutter_build` (our server's script builds the Flutter web app into `web/app`). Nothing to do. |
| "Which passwords to copy?" from `config/passwords.yaml` | **Copy none.** Cloud generates its own database credentials, service secret and auth (JWT) keys. Quiz Night has no custom secrets yet (an LLM key arrives with the AI-quiz stretch; set it then with `serverpod cloud password set`). |
| Writes `scloud.yaml`, uploads, builds, rolls out | Wait for the 🚀 on *Rollout*. Commit `scloud.yaml` (it holds no secrets). |

Your URLs (for project ID `quiz-night`):

- **Play / QR target:** `https://quiz-night.serverpod.space/`
- API: `https://quiz-night.api.serverpod.space/` (the app finds it automatically via `/assets/assets/config.json`)
- Insights: `https://quiz-night.insights.serverpod.space/`

## 3. Redeploy after changes

```bash
cd quiz_night_server && serverpod cloud deploy
```

Every deploy clears the CDN; `index.html` is never cached, so phones pick up a new build on the next load.

## 4. What is already prepared in the code

- The server serves the built Flutter app at `/` (`FlutterRoute` in `lib/server.dart`), so the **QR, the app
  and the room code all live on one address**. The QR encodes `https://<your-domain>/?code=4821`.
- **CDN caching is on** for the web build: a day at the edge, one minute in the browser (Flutter's file names
  aren't content-hashed). That keeps first loads fast for judges on mobile data.
- **No source maps** are shipped; the instant HTML loading screen shows while the ~3 MB first load runs.
- Secrets stay out of git (`config/passwords.yaml`, `.env` are ignored).

## 5. The day before the demo (checklist)

- [ ] Deploy, open `https://quiz-night.serverpod.space/` on the **laptop you'll present from**, click
      **Hosting on a big screen? Host a game**, create a room.
- [ ] On your **phone, on mobile data (Wi-Fi off)**: scan the QR, join. Note the first-load time.
- [ ] Get 3–4 friends (or extra phones/tabs) in and play a full game: rounds, the cut, back a finalist,
      buzzer final, podium.
- [ ] Mid-question, **lock a phone for 20 s and unlock it**: it should rejoin and keep its answer.
- [ ] **Refresh a phone** mid-game: it should reopen straight into the room.
- [ ] Check the projector: the host screens are designed for 1920×1080 and scale to fit any size.
- [ ] Optional: attach a custom domain in the Console (TLS is automatic) and redeploy so the QR shows it.

## 6. If something goes wrong

- Logs: in the Console, or see <https://docs.serverpod.dev/cloud/concepts/logs>.
- A failed deploy: <https://docs.serverpod.dev/cloud/guides/recover-from-a-failed-deploy>.
- Root shows "Flutter web app not built": the `flutter_build` hook failed. Run
  `cd quiz_night_server && serverpod run flutter_build` locally to see why, fix, redeploy.
