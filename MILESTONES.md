# Quiz Night — Milestones

Each milestone ends with something you can check yourself. We stop at the end of each one
before starting the next.

| # | Milestone | You can check it by… | Status |
|---|-----------|----------------------|--------|
| 0 | **Project setup**: Serverpod 4 project scaffolded, spec saved as `CLAUDE.md` | Folders `quiz_night_server/`, `quiz_night_client/`, `quiz_night_flutter/` exist | ✅ Done |
| 1 | **Data models + elimination ("cut") logic**, with unit tests | `cd quiz_night_server && dart test test/unit` → 33 tests pass | ✅ Done |
| 2 | **Game server**: create/join room, questions, answers, scoring, reveal, end-of-round cut, buzzer final, live updates | `cd quiz_night_server && dart test` → 52 tests pass (33 cut logic + 19 full-game integration) | ✅ Done |
| 3 | **Flutter: join + lobby**: home screen (Host / Join), room code + QR, live lobby list | `cd quiz_night_flutter && flutter test` → 31 tests pass; then open two browser tabs, create a room in one, join from the other, see the player appear live | 🟡 Built + tested; live check pending |
| 4 | **Flutter: playing a round**: question + countdown, answer buttons, reveal, leaderboard | `flutter test` → 74 tests pass; then play one round end to end from a host tab + 2 player tabs | 🟡 Built + tested; live check pending |
| 5 | **Flutter: elimination + spectator**: one-by-one reveal, "eliminated" banner, shadow answers, back a finalist | `flutter test` → 96 tests pass; then play to a cut: names reveal one by one, knocked-out phones switch to spectating, back a finalist, host can use the wildcard | 🟡 Built + tested; live check pending |
| 6 | **Flutter: buzzer final + podium** | `flutter test` → 136 tests pass, `dart test` (server) → 52; then play to the end: finalists buzz head to head, podium shows who backed the winner | 🟡 Built + tested; live check pending |
| 7 | **Reconnect + phone polish**: survives tab sleep/refresh, mobile layouts, light loading screen | `flutter test` → 148 tests pass (incl. 360px phone-layout checks); then refresh a phone mid-game: it reopens straight into the room | 🟡 Built + tested; live check pending |
| R | **Redesign** to the Quiz Night design system + prototype (blackboard, chalk, maroon, gold). Phases below | Every screen rendered with the real fonts and compared to the prototype; `flutter test` → 189, `dart test` → 58 | ✅ Built + tested; live check pending |
| 8 | **Deploy**: public HTTPS URL, QR points to it | Follow [DEPLOY.md](DEPLOY.md) (Serverpod Cloud); then scan the QR on your phone over mobile data and play | 🟡 Prepared (CDN caching, build hook verified, guide); waiting on your Cloud account + launch |
| 9 | **Stretch**: AI-generated quizzes, tiebreaker rounds, game history | — | ⏳ |

## Redesign (Milestone R)
Source: `Quiz Night Design System.dc.html` + `Quiz Night Prototype.html` (Claude Design export).

| Phase | What | Status |
|-------|------|--------|
| R1 | **Server:** 4-digit numeric room codes; host option "show question on phones"; `projectedSurvivors` (where the danger line sits) in `RoomState` | ✅ `dart test` → 58 |
| R2 | **Foundation:** bundled fonts (Bricolage Grotesque, Figtree, Noto Sans African Latin fallback), new colour/type/spacing/radius/motion/haptic tokens, crest logo, chalk-dust background, initial badges, option shapes | ✅ fonts 114 KB gzipped; `flutter test` → 160 |
| R3 | **Components:** answer button states, buttons, code input, countdown bar + ring, player chip, leaderboard row + danger line, danger indicator, banners/toasts, buzzer states, podium blocks, reconnecting pill | ✅ |
| R4 | **Phone screens:** loading, join, waiting, answer, locked, too late, result, survived, eliminated, back a finalist, watching, buzzer, final placement | ✅ |
| R5 | **Host screens** on a 1920×1080 canvas scaled to fit: create, lobby, question (ring), reveal (bars), standings board, elimination stamps, final desks, podium | ✅ `flutter test` → 189 |

Decisions: final is answered by tapping on the phone (server-checked), not out loud; 4-digit numeric codes;
the host chooses whether phones show the question text; fonts are downloaded from google/fonts (OFL) and subset.
The landing page is the join form (prototype "Join"); hosts use the "Host a game" link. Host screens
are laid out on a 1920×1080 canvas and scaled to fit. A small Noto Sans Symbols 2 subset (3 KB) supplies
✓ ✕ ▲ ▼ ★ ⏱, which none of the text fonts contain.
Deferred (need new server features): tiebreaker round, host-disconnected / players-reconnecting presence, AI topic
(shown as "coming soon").

## Flutter architecture (from Milestone 3)
- **State management: `flutter_bloc` Cubits**, one per job: `HomeCubit`, `JoinCubit`, `HostSetupCubit`, `RoomCubit`.
  Widgets only render state and forward taps. `setState` is only used for text-field controllers.
- **Repositories behind interfaces** (`LobbyRepository`, `GameRepository`, `SeatRepository`); Serverpod and
  browser-storage implementations are passed in at the app root, so tests use mocks.
- **Design tokens:** `AppColors`, `AppTextStyles`, `AppSpacing`/`AppRadii`/`AppIconSizes`, `AppTheme` in `lib/core/theme/`.
- **Tests:** `test/cubits/` (bloc_test + mocktail) and `test/widgets/`.

## Load size (measured in Milestone 7)
First visit downloads about 3 MB gzipped. Roughly three-quarters is Flutter's rendering engine
(CanvasKit: 2.2 MB on Chrome, 2.9 MB on Safari) from Google's CDN, which is fast and often already cached.
Our app (`main.dart.js`) is 0.85 MB, mostly the Flutter framework. Removing the unused sign-in UI saved only
26 KB, so it stays for the game-history stretch. What helps: an instant HTML loading screen, keeping the
engine on the CDN, and (Milestone 8) serving gzip without source maps.

## Decisions made so far (tell me if you disagree)
- **No sign-up for players or host.** Joining gives each player a secret token, and creating a room gives the
  host one. The server checks the token on every action, so nobody can answer as someone else or press host
  buttons. (The spec says to use Serverpod auth; making judges sign up by email to play felt like too much
  friction. Auth stays wired in for the "game history" stretch.)
- **Questions come from a built-in bank** (40 round + 12 harder final questions) until the AI generator is built.
- **The server reveals a question by itself when time runs out**, or as soon as everyone has answered. So the game
  can't stall if the host's laptop tab goes to sleep.
- **The buzzer final keeps its own score** (1000 per correct buzz). Round scores decide who reaches the final;
  the final decides the podium.
- `final` is a reserved word in Dart, so the room status is `buzzerFinal` and the spec's `FinalEndpoint` is
  `BuzzerEndpoint` (`client.buzzer.buzz(...)`).
- Secrets stay out of git: `config/passwords.yaml` and `.env` are ignored; commit-safe templates are
  `config/passwords.example.yaml` and `.env.example`.
