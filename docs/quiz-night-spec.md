# Quiz Night: product and technical spec

A stack-neutral description of Quiz Night as built (Serverpod + Flutter web, October 2026), so it can be rebuilt in another stack (e.g. **Go + Next.js**). Every number here comes from the current code. Section 14 maps each part to Go and Next.js.

---

## 1. Product

**Pitch:** "Kahoot gives everyone a participation trophy. We bring back the secondary school quiz competition: survive the round, or go home."

- A host puts questions on a big screen (projector or TV). Players answer on their own phones in the browser: no app, no account.
- After each round the bottom of the leaderboard is **knocked out**, until a few finalists face a **buzzer final**. A podium ends the game.
- Knocked-out players stay engaged as **spectators**: they keep answering for a *shadow score* and **back a finalist**.
- Audience: any crowd (friends, teams, churches and youth groups, events, classrooms), styled after school quiz competitions.

**Roles and views**

| Role | Device | View |
|---|---|---|
| Host | Laptop on a projector or TV | Big-screen layout: room code + QR, question, timer, leaderboard, cuts, podium |
| Player | Phone | Answer buttons, buzzer, own status |
| Spectator | Phone | Player layout with an "eliminated" banner, shadow answers, back a finalist |

---

## 2. Game flow

```
Lobby → Round 1 (N questions) → Cut → Round 2 → Cut → … → Buzzer final (finalists) → Podium
```

1. **Create:** host picks the rules (section 3) and gets a **4-digit room code** and a QR code linking to `/join?code=1234`.
2. **Lobby:** players join with the code and a nickname; the lobby updates live. The host can **remove a player** or **lock the room**.
3. **Start:** needs at least 2 players. The **30-minute game clock** starts (section 7).
4. **Question:** shown on every screen at once with a countdown. Players tap one of four answers (A–D). The server timestamps answers and rejects late ones.
5. **Reveal:** at zero the server reveals the answer (auto-reveal), or the host reveals early. Answer counts per option are shown only now.
6. **Standings:** the leaderboard with a **danger line** (who would be cut if the round ended now).
7. **Cut** (end of round): the server ranks active players, applies the rule, and marks the bottom ones eliminated. Clients play a one-by-one reveal ("OUT" stamps), then "N SURVIVE".
8. Repeat rounds until the survivors are at most `finalistTarget`. They become **finalists**.
9. **Buzzer final:** fixed number of questions. First finalist to buzz answers (tap on phone). Right = points; wrong = locked out of that question and others may buzz.
10. **Podium:** top three, and "who backed the winner".

---

## 3. Rules

### Host settings (validated on the server)

| Setting | Values in the UI | Server range | Default |
|---|---|---|---|
| Elimination rule | Bottom 30%, Auto-scaled, Sudden death | enum | Bottom 30% |
| Questions per round | 3, 5, 8, 10 | 1–20 | 5 |
| Finalists | 2, 3, 4 | 2–10 | 3 |
| Seconds per question | 15, 20, 30 | 5–120 | 20 |
| Rounds before final (auto-scaled only) | 2, 3, 4 | 1–10 | 3 |
| Question on phones | On / Off | bool | On (Off: phones show only the answer buttons) |
| Final questions | not in UI | 1–12 | 5 |
| Elimination percent | not in UI | 0–1 exclusive | 0.3 |

### Elimination rules

- **Bottom percent** (default): cut `max(1, round(active × 0.3))` each round.
- **Auto-scaled:** keep fraction `(finalistTarget / startingPlayers)^(1 / roundsBeforeFinal)` per round, so any room size reaches the finalists in the same number of rounds. Target survivors = `round(startingPlayers × keep^round)`, capped at `active − 1` (always cut someone); in the last round, the target is `finalistTarget`.
- **Sudden death:** a wrong or missed answer knocks you out right after that question (not at the end of the round).
- **Never below** `max(finalistTarget, 2)` survivors; never eliminate everyone. Sudden death spares the best-ranked wrong answerers if needed to keep 2.

### Ranking (for cuts)

1. Highest **cumulative score** across the game.
2. Then **fastest total time of correct answers** (ties at the cut-off go to the faster player; the cut reports `tieBrokenBySpeed`).
3. Then earliest join (deterministic).

### Scoring

- **Round answer:** correct = `max(500, round(1000 × timeRemaining / timeLimit))`; wrong or missed = 0. One answer per player per question.
- **Grace:** answers up to **500 ms** after the deadline are accepted (network latency). The server clock is the only clock.
- **Spectators:** their answers score a **shadow score** only, which never affects ranking.
- **Buzzer final:** correct = **1000 final points**. Wrong = locked out for that question. After buzzing, the holder gets **at least 8 seconds** to answer. If every finalist is locked out, the question reveals.
- **Podium:** finalists ranked by final points, then game score.

### Extras

- **Host wildcard:** once per game, before the final, rescue one eliminated player (back to active, or finalist if finalists are decided).
- **Back a finalist:** spectators pick the finalist they think will win, before the final. Revealed at the podium.
- **Tiebreak question mode:** modelled (`tiebreakMode = suddenDeath`) but **not built**; ties are decided by speed.

---

## 4. Data model

### Tables

**room**
| Column | Type | Notes |
|---|---|---|
| id | int PK | |
| code | string, unique | 4 digits (5 if 10 random tries collide) |
| hostToken | string, server-only | 128-bit random hex |
| status | enum RoomStatus | `lobby`, `question`, `reveal`, `elimination`, `tiebreak` (unused), `buzzerFinal`, `finished` |
| currentRound | int | 0 in the lobby |
| currentQuestionIndex | int | 1-based within the round, 0 = none |
| currentQuestionId | int? | |
| questionsPerRound, eliminationRule, eliminationPercent, finalistTarget, roundsBeforeFinal, tiebreakMode, finalQuestionCount, timeLimitSeconds, showQuestionOnPhones | | host settings |
| wildcardUsed | bool | |
| locked | bool | host closed the room to new players |
| startingPlayerCount | int? | set at Start |
| questionStartedAt, questionEndsAt | timestamp? | server clock |
| lastCutRound | int | makes the cut idempotent |
| finalQuestionsPlayed | int | |
| buzzerHolderId | int? | |
| lastElimination | json (EliminationEvent)? | |
| createdAt | timestamp | deleted 24 h after this |
| startedAt | timestamp? | 30-minute game clock starts here |
| lastActivityAt | timestamp | rooms idle 30 min close |
| endReason | enum? | `completed`, `timeUp`, `inactive` |

**player**: id, roomId (cascade), nickname, token (server-only, unique), score, shadowScore, finalScore, totalCorrectAnswerMs, status (`active`, `eliminated`, `finalist`), eliminatedInRound?, backedPlayerId?, joinedAt.

**question**: id, roomId (cascade), orderIndex, round (0 for the final), isFinal, isTiebreak, text, options (4 strings), correctIndex, timeLimitSeconds.

**answer**: id, playerId (cascade), questionId (cascade), choiceIndex, answeredAt, pointsAwarded, isShadow.

**buzz**: id, playerId (cascade), questionId (cascade), buzzedAt, wasCorrect?, lockedOut.

Deleting a room cascades to everything else.

### Pushed to clients (not tables)

**RoomState** (every change sends a full snapshot to everyone in the room):
`code, status, round, questionsPerRound, finalistTarget, finalQuestionCount, finalQuestionsPlayed, eliminationRule, wildcardUsed, locked, sessionEndsAt?, endReason?, question?, questionEndsAt?, serverTime, players[], lastElimination?, buzzerHolderId?, buzzWinnerId?, showQuestionOnPhones, projectedSurvivors?`

- **QuestionView:** `id, round, indexInRound, isFinal, text, options, timeLimitSeconds, correctIndex?` (null while open), `answerCounts?` (null while open and in the final).
- **PlayerView:** `id, nickname, score, shadowScore, finalScore, status, eliminatedInRound?, backedPlayerId?` (only once finished), `hasAnswered, lastPoints?` (after reveal), `lockedOut`. **Never the token.**
- **EliminationEvent:** `round, eliminatedPlayerIds` (reveal order: worst first, the bubble last), `survivorsCount, tieBrokenBySpeed, finalistsDecided`.
- `serverTime` lets clients compute a clock offset so countdowns follow the server.
- `projectedSurvivors`: the danger line; null in the lobby, sudden death and the final.

**Other results:** `CreateRoomResult {roomCode, hostToken}`, `JoinResult {roomCode, playerId, playerToken}`, `AnswerResult`, `BuzzResult {gotBuzzer, reason?}`.

**Errors:** `QuizException {code, message}` with codes `roomNotFound, playerNotFound, notHost, invalidState, nicknameTaken, invalidInput, tooLate, alreadyAnswered, notAllowed, rateLimited, roomFull, roomLocked`. The `message` is user-facing.

---

## 5. API

Request/response calls plus one live stream per room. Host calls carry the `hostToken`; player calls carry the `playerToken`.

| Call | Who | Does | Rate limit (sec. 6) |
|---|---|---|---|
| `createRoom(config)` → code + hostToken | anyone | validates settings, picks a free code | 20/h per address |
| `joinRoom(code, nickname)` → playerId + token | anyone | lobby only; cleans and checks the nickname; refuses if locked, full or taken | see join limits |
| `rejoin(code, playerToken)` → JoinResult | player | recover identity after reload | 120/min per address |
| `startGame(code, hostToken)` | host | needs ≥ 2 players; starts the clock | 120/min per host token |
| `nextQuestion(code, hostToken)` | host | next question, the cut screen or the final | same |
| `reveal(code, hostToken)` | host | reveal early (also automatic at zero) | same |
| `endRound(code, hostToken)` | host | runs the cut; **idempotent** | same |
| `useWildcard(code, hostToken, playerId)` | host | once, before the final | same |
| `setLocked(code, hostToken, locked)` | host | lock or unlock joining | same |
| `removePlayer(code, hostToken, playerId)` | host | lobby only; frees the nickname, kills the token | same |
| `submitAnswer(playerToken, questionId, choiceIndex)` | player | scores, or shadow-scores spectators | 30 per 10 s per player token |
| `buzz(playerToken, questionId)` → BuzzResult | finalist | first valid buzz wins | same |
| `submitBuzzAnswer(playerToken, questionId, choiceIndex)` → bool | buzzer holder | right = 1000 final points | same |
| `backFinalist(playerToken, finalistId)` | spectator | before the final | same |
| `watchRoom(code)` → stream of RoomState | anyone with the code | full snapshot first, then every change | 300 new/min and 60 open per address |

**Live stream rules:** subscribe first, then send the snapshot, so no update slips in between. Re-subscribing after a disconnect returns a fresh snapshot: that is the whole reconnect story. Phones re-subscribe when the tab becomes visible again (mobile browsers suspend background tabs).

---

## 6. Security and abuse controls

### Rate limits

Per address, sized so a whole room on one Wi-Fi (shared address) isn't blocked; tight per token. Counters in memory (one instance); move to Redis with more than one instance.

| What | Limit |
|---|---|
| Create a room | 20 per hour per address |
| Join | 60 per minute per address **and** 20 attempts per minute per room |
| Wrong room codes | more than **6 in a minute blocks that address for 5 minutes** (even for a correct code) |
| Reconnect (`rejoin`) | 120 per minute per address |
| Host controls | 120 per minute per host token |
| Answers, buzzes, backing | 30 per 10 seconds per player token |
| Live streams | 300 new per minute, 60 open at once, per address |

- **Client address:** behind a proxy, the **last** `X-Forwarded-For` entry (added by the proxy, can't be faked); otherwise the socket address.
- **Error:** `rateLimited`, "Too many requests. Wait a moment and try again."

### Room controls

- **20 players per room** (MVP). Traffic grows with the square of this, because each change sends the full player list to every phone; batch mid-question updates before raising it.
- **Lock room:** host toggle; joiners get `roomLocked`.
- **Remove player:** lobby only; the removed phone shows "You were removed" with a way home.

### Nicknames

- 1–20 characters after cleaning.
- **Cleaning:** remove control, format (zero-width, right-to-left overrides), private-use and unassigned characters; fold whitespace runs to one space; trim. Keep accented letters (ọ, ṣ, ẹ, ɗ, ɓ…) and emoji.
- **Filter:** lower-case and map look-alikes (`0→o 1→i !→i 3→e 4→a @→a 5→s $→s 7→t 8→b`).
  - **Blocked anywhere** in the letters-only form: strong words (`fuck, shit, cunt, nigger, nigga, faggot, bitch, whore, slut, rapist, porn, wank, bastard, retard`).
  - **Blocked only as a whole word:** short words that hide in names (`ass, arse, cock, dick, piss, tit, tits, sex, rape, nazi, hitler, kkk, fag`), so Cassandra, Dickens, Glass, Titus pass.
  - Unknown misspellings get through; the host's remove button is the backstop.
- Nicknames are unique per room, case-insensitive, compared after cleaning.

### Tokens and auth

- Host and player tokens: 128-bit, secure random, stored server-side, **never sent to other clients**.
- Host token compared in **constant time**.
- **No accounts** for players or hosts. Planned: optional host sign-in only for AI questions, saved quizzes and history.
- Unused sign-up/login endpoints must not exist (they could be abused to send emails).

### Web security headers (every page)

```
Content-Security-Policy: default-src 'self'; script-src 'self' <engine CDN>; style-src 'self' 'unsafe-inline';
  img-src 'self' data: blob:; font-src 'self' data: <font CDN>; connect-src 'self' <API https> <API wss>;
  worker-src 'self' blob:; object-src 'none'; base-uri 'self'; form-action 'self'; frame-ancestors 'none'
Strict-Transport-Security: max-age=31536000; includeSubDomains
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: camera=(), microphone=(), geolocation=(), payment=(), usb=(), screen-wake-lock=(self)
Cross-Origin-Opener-Policy: same-origin
```

(Flutter needed `'wasm-unsafe-eval'` and Google's CDN for its engine; a Next.js build needs neither, but may need nonces for inline scripts.)

### Fairness invariants

- The server clock decides; never trust client time.
- Never send `correctIndex` or answer counts before the reveal.
- The cut runs in **one transaction** (rank, cut, resolve ties, update statuses, then broadcast) and is **idempotent** (`lastCutRound`).
- Buzzer: first valid buzz wins via a locked row / conditional update, so two buzzes can't both win; locked-out players can't buzz again on that question.
- Eliminated players never affect ranking, others' scores or the buzzer.
- Host-only actions verify the host token.

### Secrets and repo

- Secrets never in git (`.env`, server passwords file ignored; `.example` templates committed).
- GitHub secret scanning with push protection on.
- CI tokens read-only; actions pinned to commit SHAs; Dependabot weekly into `develop`.

---

## 7. Sessions and data lifetime

| Rule | Value | Behaviour |
|---|---|---|
| Game length | **30 minutes from Start** | Every screen shows "⏱ mm:ss left" (gold under 5 min, red under 1). At zero the game ends with `endReason = timeUp`. |
| Inactivity | **30 minutes without activity** | Any change (join, answer, buzz, host action) resets it. Ends with `endReason = inactive`. |
| Sweep | every 30 seconds | Ends rooms past either limit and broadcasts. |
| Deletion | **24 hours after creation** | Hourly sweep deletes rooms; cascades to all their data. FAQ: "One day." |
| Seat on the phone | until Leave, or the room is gone or over | Stored in local storage: `{role, code, token, playerId}`. |

**Ending early (time up or inactive):**
- Standings = finalists by final points if a final happened; otherwise **players still in, by score so far**, then the eliminated.
- The podium shows the right score (final points for finalists, game score otherwise) and a notice: *"Time's up: the game's 30 minutes ran out. These are the scores when the clock stopped."* With no final, the backers panel says *"No final this time."*
- Phones show "RESULTS SO FAR", "TIME'S UP", "You finished 2nd with 2,500 points."
- An idle **lobby** (never started) shows "ROOM CLOSED: nothing happened here for 30 minutes…" and its code stops working.

---

## 8. Screens and URLs

| URL | Screen |
|---|---|
| `/` | Landing: hero ("Survive the round. Win the night."), join card (code → `/join`), host card, game preview, how a game runs, knocked-out section |
| `/how-it-works` | Players / hosts walkthrough (tabs) |
| `/hosting` | Hosting guide: three ways to cut, setup, questions, during the game, troubleshooting |
| `/faq` | Players, hosts, privacy (accordion) |
| `/join?code=` | Join form: code + nickname; back link to the landing page |
| `/host` | New game: rule cards, pickers, AI topic ("coming soon"), plain-language summary of every choice, Create room |
| `/room/:code` | The game, for host or player |
| anything else | Not found, with links home and to join |

**Routing rules:**
- `/?code=` (old QR links) redirects to `/join?code=`.
- `/room/:code` without this device's seat for that room goes to `/join?code=`.
- On `/`, `/join` and `/host`: if the device holds a **live** seat, go back into that room (`/room/:code`). A QR for a *different* room wins. A dead seat is cleared. No check on other pages.
- Leaving a room goes to `/`.

**Host screens** are designed on a **1920×1080** canvas, scaled to fit. On portrait windows: an **800-wide** canvas (wider on tablets: `max(800, width × 1.35)`), height following the window, panes stacked. Screens: setup, lobby (code + QR, players, lock, start), question (clock ring, answered count, 2×2 options), reveal (bars), standings (danger line), cut (suspense, OUT stamps, survivors / finalists' desks), final (desks, buzzer state), podium.

**Phone screens** (max 480 wide): waiting, question, result (points, rank move), cut (survived / eliminated), spectating + back a finalist, buzzer, placement. The header has the code, phase, Sound/Muted (haptics) and Leave, with the game clock under it.

**Phone niceties:** screen wake lock in a room; vibration on key moments; reconnecting overlay; works on weak data.

---

## 9. Design system

**Look:** blackboard green, chalk white, the maroon and gold of a school uniform; a crest logo; chalk-dust dot texture.

### Colours

| Token | Hex | Use |
|---|---|---|
| board | `#0F1A15` | page |
| boardDeep | `#0B1A14` | inputs, wells |
| surface | `#16241D` | cards |
| surfaceHigh | `#1E3028` | chips, rows |
| surfaceTop | `#26392F` | highest surface |
| chalk | `#F2F0E6` | text |
| chalkSoft | `#D6DBD3` | secondary text |
| muted | `#AEB9B1` | captions |
| faint | `#7F8C85` | hints |
| line | `#F2F0E6` at 14% | hairlines |
| green | `#1A3A2C` | crest fill, selected |
| greenLine / mint / mintPale | `#5FA683` / `#8DC6A7` / `#C3E3D0` | accents |
| gold | `#E0B53A` | primary actions, prizes, "you" |
| goldLight / goldDeep / goldInk | `#F2CF6E` / `#3A2D05` / `#1B1500` | text on gold = goldInk |
| maroon | `#9C2D44` | danger, destructive |
| maroonDarkest | `#2A0A10` | eliminated cards |
| correct / wrong | `#2E9E68` / `#E5484D` | answers |
| errorText | `#FF8A8E` | error text on dark |
| info / infoText | `#12324A` / `#CFE6F7` | info banners |

**Answer options** (letter + shape + colour, never colour alone):

| | Colour | Ink | Shape |
|---|---|---|---|
| A | `#1E5BC6` blue | white | ▲ triangle |
| B | `#F08A24` orange | `#1B1000` | ◆ diamond |
| C | `#C2417A` raspberry | white | ● circle |
| D | `#F4D23C` yellow | `#1B1500` | ■ square |

**Badge tones** (avatar initials, hashed from the nickname): `#8DC6A7 #E5A3AF #F2CF6E #9CC3EE #D6DBD3 #F0B07A #C9B3E8 #7FD1C2`.

**Countdown:** chalk, gold in the last 5 s, red in the last 3 s, with a pulse and a small shake.

### Type

- **Display:** Bricolage Grotesque 800, upper case (headlines, codes, numbers, tabular figures).
- **Body:** Figtree 400 / 700 / 800.
- **Fallbacks:** Noto Sans (Nigerian letters), Noto Sans Symbols 2 (✓ ✕ ▲ ▼ ★ ⏱). Fonts are bundled and subset for fast loads.
- **Phone scale:** display 56 / 40, headline 28, title 20, body 16, label 14 caps, caption 12.
- **Projector scale (1080p):** display 200 / 120, headline 72, title 56, body 36 minimum (legible from 10 m).
- **Website:** hero 44–84 (7vw), section 30–44, lead 17–20; max width 1160; gutter 16–32 (4vw); header 68; nav collapses to a Menu below 900.

### Spacing and shape

4 px base (4, 8, 12, 16, 20, 24, 32, 48, 64); radii 4, 8, 12 (buttons, inputs), 14 (answer buttons), 20 (panels), full; borders 1, 2, 3 (focus/selected); primary button 56 tall; answer buttons at least 72.

---

## 10. Copy (key lines)

- Join errors: "This game session doesn't exist. Check the code on the big screen." · "This game already started. Ask the host to open a new room." · "This room is full (20 players). Ask the host for another room." · "The host has locked this room. Ask them to unlock it." · "Pick a different nickname: it shows on the big screen."
- Removed: "YOU WERE REMOVED: The host removed you from this room. You can join again with the code on the big screen."
- Setup summary explains each choice, e.g. "Bottom 30%: After each round the lowest 30% go home; ties go to the faster player."
- Planned features in the UI say "coming soon" (AI questions, writing your own questions).

---

## 11. Next feature: AI-generated questions (designed, not built)

1. Host types a topic and picks Easy / Mixed / Hard → **Generate**.
2. Server asks an LLM (Claude via the Anthropic API, key server-side only) for exactly the needed round questions plus harder final ones and a few spares, using **structured outputs** (JSON schema: text, 4 options, correctIndex, isFinal).
3. Server validates each question (4 distinct options, valid index, lengths, no duplicates) and replaces failures from spares.
4. Host **previews** with answers, removes or replaces single questions, then creates the room.
5. Game plays the pack in order, falling back to the built-in bank.
6. Storage: `question_pack` + `pack_question`; the room gets `packId?`.
7. Guards: per-address limit (e.g. 5 generations/hour), a daily spend cap, topic ≤ 100 characters passed as data, family-friendly prompt, refusal handling with model fallback.
8. Estimated cost and time per 20–30 question game: about $0.05–0.15 and 10–30 s on the main model (unmeasured).

---

## 12. Testing approach

- **Server:** unit tests for the cut logic (ranking, percentages, auto-scaled maths, ties, the 2-survivor floor), scoring, rate limiter, nickname filter, token comparison, headers; integration tests against a real database for full games, cuts, buzzer, limits, lock/remove, expiry and cleanup.
- **Client:** state/logic unit tests; screen tests for every view; **layout tests at 360×640, 390×844, a portrait tablet and 1920×1080** that fail on any overflow; flows through the real router (join, host, resume, not-found).
- **CI never calls paid APIs**: the AI generator sits behind an interface with a fake.

---

## 13. Delivery

- **Branches:** feature branch → PR into `develop` → PR into `main`. `main` is protected: PR only, checks `server`, `app` and `web` must pass on an up-to-date branch, no force pushes.
- **Commits:** Conventional Commits; feature and test commits separate; small batches.
- **CI jobs:** server (format, generated code up to date, analyze, tests), app (format, analyze, tests), web (release build, gzipped app-code budget 1200 KB).
- **CD:** merge into `main` → re-run CI → deploy → smoke test `/`, `/faq` and the app config.
- **Hosting today:** Serverpod Cloud (managed Postgres, HTTPS, CDN), one address for the site, API and QR.
- **Performance target:** first load usable in 2–5 s on 4G; instant HTML loading screen; small bundle; preconnect to any CDN.

---

## 14. Rebuilding in Go + Next.js

| Concern | Go backend | Next.js frontend |
|---|---|---|
| Project shape | One Go service (API + WebSocket), Postgres; Redis once there's more than one instance | Next.js App Router; marketing pages static, game pages client-side |
| HTTP API | `net/http` (Go 1.22+ routing) or `chi`; JSON over POST, one handler per call in section 5; errors as `{code, message}` with the same codes | Typed client generated from an OpenAPI spec, or a hand-written `fetch` wrapper sharing TypeScript types |
| Real-time | WebSocket per room viewer (`github.com/coder/websocket`); a room hub fans out full `RoomState` snapshots; subscribe before snapshot | One WebSocket per room screen; reconnect with backoff, re-subscribe on `visibilitychange`; keep the latest snapshot in state |
| Fan-out across instances | Redis pub/sub channel `room-<code>` | n/a |
| Database | Postgres with `pgx`; queries via `sqlc`; migrations via `goose` or `atlas`; transactions with `SELECT … FOR UPDATE` for the cut, buzzer, joins | n/a |
| Timers | Per-question auto-reveal (`time.AfterFunc`, re-checked inside a transaction); 30 s expiry sweep and hourly cleanup (`time.Ticker`); with several instances, use a DB advisory lock or one worker | Countdown from `questionEndsAt` / `sessionEndsAt` + server-clock offset from `serverTime` |
| Randomness and tokens | `crypto/rand` for codes and tokens; `crypto/subtle.ConstantTimeCompare` for host tokens | Seat in `localStorage` |
| Rate limits | In-memory windows per key (or `golang.org/x/time/rate`), Redis with several instances; read the last `X-Forwarded-For` entry from a trusted proxy | Show the server's message |
| Nickname filter | Unicode categories via `unicode` (`Cc, Cf, Co`) plus the same lists | n/a |
| Security headers | Middleware on the API | `headers()` in `next.config` or middleware; CSP with nonces for Next's inline scripts; `connect-src` must include the API and its `wss:` URL |
| Routing | n/a | `app/(site)/page.tsx`, `how-it-works`, `hosting`, `faq`; `app/join/page.tsx`; `app/host/page.tsx`; `app/room/[code]/page.tsx`; redirects in middleware (`/?code=`, live-seat resume) |
| State | n/a | A reducer or Zustand store per room screen (the snapshot, my choice, connection status) |
| Design tokens | n/a | CSS variables (section 9) in Tailwind's theme; `next/font` for Bricolage Grotesque and Figtree (self-hosted subsets) |
| Host canvas | n/a | A fixed 1920×1080 (or 800-wide portrait) stage scaled with CSS `transform: scale()` to fit the window |
| QR | n/a | Render client-side (e.g. `qrcode` package) pointing to `https://<site>/join?code=` |
| Tests | `go test` with a real Postgres (testcontainers or a CI service); table tests for cut logic and scoring | Vitest + Testing Library for logic and components; Playwright for flows and layouts at the four viewport sizes |
| Deploy | Container on Fly.io, Render or Cloud Run (supports long-lived WebSockets); managed Postgres | Vercel or the same host; if split, set CORS and the API URL per environment |
| CI | `go vet`, `staticcheck`, `golangci-lint`, `go test`; migration check | `next lint`, type-check, tests, build with a bundle-size budget |

**Keep the same contracts:** the RoomState shape, error codes, rate limits, session rules and URLs above, so the two clients and any future native app behave the same.
