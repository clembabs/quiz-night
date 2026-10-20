BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "answer" (
    "id" bigserial PRIMARY KEY,
    "playerId" bigint NOT NULL,
    "questionId" bigint NOT NULL,
    "choiceIndex" bigint NOT NULL,
    "answeredAt" timestamp without time zone NOT NULL,
    "elapsedMs" bigint NOT NULL,
    "isCorrect" boolean NOT NULL,
    "pointsAwarded" bigint NOT NULL,
    "isShadow" boolean NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "answer_player_question_idx" ON "answer" USING btree ("playerId", "questionId");
CREATE INDEX "answer_question_idx" ON "answer" USING btree ("questionId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "buzz" (
    "id" bigserial PRIMARY KEY,
    "playerId" bigint NOT NULL,
    "questionId" bigint NOT NULL,
    "buzzedAt" timestamp without time zone NOT NULL,
    "wasCorrect" boolean,
    "lockedOut" boolean NOT NULL DEFAULT false
);

-- Indexes
CREATE UNIQUE INDEX "buzz_player_question_idx" ON "buzz" USING btree ("playerId", "questionId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "player" (
    "id" bigserial PRIMARY KEY,
    "roomId" bigint NOT NULL,
    "nickname" text NOT NULL,
    "token" text,
    "score" bigint NOT NULL DEFAULT 0,
    "shadowScore" bigint NOT NULL DEFAULT 0,
    "finalScore" bigint NOT NULL DEFAULT 0,
    "totalCorrectAnswerMs" bigint NOT NULL DEFAULT 0,
    "status" text NOT NULL DEFAULT 'active'::text,
    "eliminatedInRound" bigint,
    "backedPlayerId" bigint,
    "joinedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "player_room_idx" ON "player" USING btree ("roomId");
CREATE UNIQUE INDEX "player_token_idx" ON "player" USING btree ("token");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "question" (
    "id" bigserial PRIMARY KEY,
    "roomId" bigint NOT NULL,
    "orderIndex" bigint NOT NULL,
    "round" bigint NOT NULL,
    "isFinal" boolean NOT NULL DEFAULT false,
    "isTiebreak" boolean NOT NULL DEFAULT false,
    "text" text NOT NULL,
    "options" json NOT NULL,
    "correctIndex" bigint NOT NULL,
    "timeLimitSeconds" bigint NOT NULL
);

-- Indexes
CREATE INDEX "question_room_idx" ON "question" USING btree ("roomId", "orderIndex");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "room" (
    "id" bigserial PRIMARY KEY,
    "code" text NOT NULL,
    "hostToken" text,
    "status" text NOT NULL DEFAULT 'lobby'::text,
    "currentRound" bigint NOT NULL DEFAULT 0,
    "currentQuestionIndex" bigint NOT NULL DEFAULT 0,
    "currentQuestionId" bigint,
    "questionsPerRound" bigint NOT NULL,
    "eliminationRule" text NOT NULL,
    "eliminationPercent" double precision NOT NULL,
    "finalistTarget" bigint NOT NULL,
    "roundsBeforeFinal" bigint NOT NULL,
    "tiebreakMode" text NOT NULL,
    "finalQuestionCount" bigint NOT NULL,
    "timeLimitSeconds" bigint NOT NULL,
    "wildcardUsed" boolean NOT NULL DEFAULT false,
    "startingPlayerCount" bigint,
    "questionStartedAt" timestamp without time zone,
    "questionEndsAt" timestamp without time zone,
    "lastCutRound" bigint NOT NULL DEFAULT 0,
    "finalQuestionsPlayed" bigint NOT NULL DEFAULT 0,
    "buzzerHolderId" bigint,
    "lastElimination" json,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "room_code_idx" ON "room" USING btree ("code");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "answer"
    ADD CONSTRAINT "answer_fk_0"
    FOREIGN KEY("playerId")
    REFERENCES "player"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "answer"
    ADD CONSTRAINT "answer_fk_1"
    FOREIGN KEY("questionId")
    REFERENCES "question"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "buzz"
    ADD CONSTRAINT "buzz_fk_0"
    FOREIGN KEY("playerId")
    REFERENCES "player"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "buzz"
    ADD CONSTRAINT "buzz_fk_1"
    FOREIGN KEY("questionId")
    REFERENCES "question"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "player"
    ADD CONSTRAINT "player_fk_0"
    FOREIGN KEY("roomId")
    REFERENCES "room"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "question"
    ADD CONSTRAINT "question_fk_0"
    FOREIGN KEY("roomId")
    REFERENCES "room"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR quiz_night
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('quiz_night', '20261020101839017', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261020101839017', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260824182259319', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182259319', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260924105404509', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105404509', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260924105232991', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105232991', "timestamp" = now();


COMMIT;
