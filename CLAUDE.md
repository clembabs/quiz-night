# Quiz Night — Serverpod Hackathon Project

Real-time multiplayer **elimination quiz**, styled after secondary school quiz competitions.
Kahoot-style questions on everyone's phone, but after each round the server ranks players and
**eliminates the bottom group** until ~3 finalists remain for a head-to-head **buzzer final**.

Backend: **Serverpod** (Dart). Client: **Flutter web** (primary target).

Pitch: *"Kahoot gives everyone a participation trophy. We bring back the secondary school quiz
competition: survive the round, or go home."*

## Project layout (standard Serverpod)
- `quiz_night_server/` — Serverpod server (models in `lib/src/models/*.spy.yaml`, endpoints in `lib/src/endpoints/`)
- `quiz_night_client/` — generated client (never edit by hand; run `serverpod generate`)
- `quiz_night_flutter/` — Flutter app (host screen + player screen + spectator view)

Scaffold with `serverpod create quiz_night`. After changing models: `serverpod generate`, then create/apply migrations.

## Platform decision
- **Flutter web is the demo target.** Judges scan a QR and play in their phone browser — no install, works on iPhone and Android.
- Chosen over Next.js because Serverpod's generated typed Dart client (incl. streaming) works directly in Flutter; a JS frontend would need a hand-written client and streaming protocol.
- Android APK = bonus if time allows. Native iOS/Android = post-hackathon.
- **Mobile-first layouts**, one app, route/role decides the view:
  - **Player view** — phone-sized: big thumb-friendly answer buttons, big buzzer.
  - **Host view** — widescreen for laptop + projector: room code + QR, question, timer, leaderboard, elimination reveal.
  - **Spectator view** — player layout with an "eliminated" banner, shadow answers, back-a-finalist.
- **Load size matters** (judges may be on weak Wi-Fi / mobile data): lightweight HTML loading screen in `web/index.html`, minimal fonts/images, no heavy packages. Test first load on a phone over mobile data.
- **Deployment:** Serverpod server + Flutter web build on a public HTTPS URL; QR points to that URL. Deploy and test the day before the demo — localhost won't work for judges' phones.
- Mobile browsers suspend background tabs → streams drop. Reconnect handling is a must-have.

## Game flow
```
Lobby → Round 1 (N Qs) → ✂️ Cut → Round 2 → ✂️ Cut → ... → 🏆 Buzzer Final (top ~3) → Podium
```
1. Host creates a room (picks elimination rule, questions per round, finalist target) → gets a 4–6 char code + QR.
2. Players join with code + nickname; lobby updates live.
3. **Round:** each question appears on all screens at once with a countdown. Players answer; server timestamps and rejects late answers. Reveal + leaderboard after each question.
4. **Elimination phase** (end of each round): server ranks active players, applies the cut, resolves ties, marks players eliminated. Clients play a dramatic one-by-one reveal of who's out.
5. Repeat rounds until active players ≤ `finalistTarget`.
6. **Buzzer final:** question appears; first finalist to buzz gets to answer. Correct = points; wrong = locked out for that question, others may buzz. Fixed number of final questions.
7. Podium + "who backed the winner" reveal.

## Elimination rules (host chooses at room creation)
- **bottomPercent** (default): cut lowest ~30% of active players each round.
- **autoScaled:** keep fraction `(finalistTarget / startingPlayers)^(1 / roundsBeforeFinal)` each round, so any room size reaches ~3 finalists in the same number of rounds (e.g. 20 players, 3 rounds → ~53% survive: 20 → 11 → 6 → 3).
- **suddenDeath:** a wrong answer (or no answer) eliminates you immediately.
- **Host wildcard** (optional, any rule): host can rescue one eliminated player once per game.
- Always keep at least 2 active players; never eliminate everyone.
- Ranking for cuts uses **cumulative score** across the game.

### Ties at the cutoff
- Default: break by total answer time (faster cumulative correct answers survive).
- Optional `tiebreakMode = suddenDeath`: tied players get a tiebreaker question while everyone else watches; first correct (then fastest) survives.

### Eliminated players (keep them engaged — judges get knocked out early)
- Become **spectators**: still see every question and can answer for a **shadow score** (stored, never affects ranking).
- Before the final, each eliminated player **backs a finalist**; revealed at the podium.

## Data models
- **Room** (table `room`): `code` (unique index), `hostUserId`, `status: RoomStatus`, `currentRound`, `currentQuestionIndex`, `questionsPerRound`, `eliminationRule: EliminationRule`, `eliminationPercent`, `finalistTarget`, `tiebreakMode: TiebreakMode`, `wildcardUsed: bool`, `startingPlayerCount?`, `questionStartedAt?`, `questionEndsAt?`
- **RoomStatus** (enum): `lobby`, `question`, `reveal`, `elimination`, `tiebreak`, `final`, `finished`
- **EliminationRule** (enum): `bottomPercent`, `autoScaled`, `suddenDeath`
- **TiebreakMode** (enum): `speed`, `suddenDeath`
- **PlayerStatus** (enum): `active`, `eliminated`, `finalist`
- **Player**: `roomId`, `nickname`, `score`, `shadowScore`, `totalCorrectAnswerMs`, `status: PlayerStatus`, `eliminatedInRound?`, `backedPlayerId?`
- **Question**: `roomId`, `orderIndex`, `round`, `isFinal: bool`, `isTiebreak: bool`, `text`, `options: List<String>`, `correctIndex`, `timeLimitSeconds`
- **Answer**: `playerId`, `questionId`, `choiceIndex`, `answeredAt`, `pointsAwarded`, `isShadow: bool`
- **Buzz**: `playerId`, `questionId`, `buzzedAt`, `wasCorrect?`, `lockedOut: bool`
- **EliminationEvent** (no table, part of RoomState): round, list of eliminated players in reveal order, survivors count, tiebreak info
- **RoomState** (no table, pushed to clients): status, round, current question (WITHOUT `correctIndex` until reveal), time remaining, players with scores + status, latest EliminationEvent, current buzzer holder (final)

## Endpoints
- `RoomEndpoint`
  - `createRoom(config)` → code
  - `joinRoom(code, nickname)` → Player (lobby only)
  - `startGame(code)`, `nextQuestion(code)`, `reveal(code)`, `endRound(code)` (host only; `endRound` runs the cut)
  - `useWildcard(code, playerId)` (host only, once per game)
  - `watchRoom(code)` → `Stream<RoomState>`
- `AnswerEndpoint`
  - `submitAnswer(playerId, questionId, choiceIndex)` — active players score; eliminated players stored as shadow answers
- `FinalEndpoint`
  - `buzz(playerId, questionId)` → whether you got the buzzer
  - `submitBuzzAnswer(playerId, questionId, choiceIndex)`
  - `backFinalist(playerId, finalistId)` (eliminated players, before final starts)

Real-time via Serverpod message bus:
```dart
Stream<RoomState> watchRoom(Session session, String code) async* {
  final room = await Room.db.findFirstRow(session, where: (t) => t.code.equals(code));
  if (room == null) throw RoomNotFoundException();
  yield await buildState(session, room);                          // initial snapshot
  yield* session.messages.createStream<RoomState>('room-$code');  // live updates
}
// On any state change (join, answer, reveal, elimination, buzz):
session.messages.postMessage('room-$code', await buildState(session, room));
```

## Rules / invariants
- Server is the source of truth for time: set `questionStartedAt`/`questionEndsAt` server-side; never trust client clocks.
- Never send `correctIndex` to clients before reveal.
- Scoring (rounds): correct = `1000 × (timeRemaining / timeLimit)`, floor ~500. Wrong = 0. One answer per player per question.
- Elimination cut runs inside a **single DB transaction**: rank active players → compute cutoff → resolve ties → update statuses → then broadcast. Must be idempotent (calling `endRound` twice must not cut twice).
- Eliminated players can never affect ranking, scores of others, or the buzzer.
- **Buzzer fairness:** first valid buzz wins, decided by the server. Use a transaction / conditional update so two simultaneous buzzes can't both win. Locked-out players can't buzz again on that question.
- Host-only actions must verify the caller is the room host.
- Timer: host app calls `reveal()` at zero; server enforces deadline in `submitAnswer`. Upgrade: future calls to auto-reveal / auto-end-round if host disconnects.
- Reconnect: re-subscribing to `watchRoom` returns a fresh snapshot including the player's own status.

## Scope
**Must have:** create/join room, live lobby, synced questions, answer submission, reveal, leaderboard, end-of-round elimination (bottomPercent), eliminated → spectator view, final podium, QR join, reconnect (re-subscribe → fresh snapshot), public web deployment.
**Should have:** buzzer final, autoScaled rule, tie handling, dramatic elimination reveal animation.
**Stretch:** AI-generated quizzes (host types topic → server calls LLM → questions, harder ones for the final), sudden-death rule + tiebreaker rounds, host wildcard, back-a-finalist, shadow scores, saved game history with auth module.

## Demo plan (~2 min)
QR on projector → judges join → AI generates a quiz on a topic they shout → one quick round →
dramatic elimination reveal (some judges go out and become spectators, back a finalist) →
buzzer final between the last 3 → podium.
Shows real-time sync, server-side validation, transactional elimination logic, and fair buzzer arbitration.

## Working style
- Keep Flutter UI simple; invest time in server logic (elimination + buzzer are the showpieces).
- Use Serverpod's built-in auth module rather than custom auth.
- Build must-haves end-to-end first, then layer on extras.
- Write unit tests for the cut logic (ranking, percentages, autoScaled math, ties, min-2 rule).
