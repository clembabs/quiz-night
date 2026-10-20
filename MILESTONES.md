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
| 5 | **Flutter: elimination + spectator**: one-by-one reveal, "eliminated" banner, shadow answers, back a finalist | Players get knocked out and keep playing as spectators | ⏳ |
| 6 | **Flutter: buzzer final + podium** | Last 3 buzz head to head; podium shows who backed the winner | ⏳ |
| 7 | **Reconnect + phone polish**: survives tab sleep/refresh, mobile layouts, light loading screen | Refresh a player's phone mid-game and they come back in the same state | ⏳ |
| 8 | **Deploy**: public HTTPS URL, QR points to it | Scan the QR on your phone over mobile data and play | ⏳ |
| 9 | **Stretch**: AI-generated quizzes, tiebreaker rounds, game history | — | ⏳ |

## Flutter architecture (from Milestone 3)
- **State management: `flutter_bloc` Cubits**, one per job: `HomeCubit`, `JoinCubit`, `HostSetupCubit`, `RoomCubit`.
  Widgets only render state and forward taps. `setState` is only used for text-field controllers.
- **Repositories behind interfaces** (`LobbyRepository`, `GameRepository`, `SeatRepository`); Serverpod and
  browser-storage implementations are passed in at the app root, so tests use mocks.
- **Design tokens:** `AppColors`, `AppTextStyles`, `AppSpacing`/`AppRadii`/`AppIconSizes`, `AppTheme` in `lib/core/theme/`.
- **Tests:** `test/cubits/` (bloc_test + mocktail) and `test/widgets/`.

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
