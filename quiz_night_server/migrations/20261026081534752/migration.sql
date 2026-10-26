BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "pack_question" (
    "id" bigserial PRIMARY KEY,
    "packId" bigint NOT NULL,
    "orderIndex" bigint NOT NULL,
    "isFinal" boolean NOT NULL,
    "text" text NOT NULL,
    "options" json NOT NULL,
    "correctIndex" bigint NOT NULL
);

-- Indexes
CREATE INDEX "pack_question_pack_idx" ON "pack_question" USING btree ("packId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "question_pack" (
    "id" bigserial PRIMARY KEY,
    "topic" text NOT NULL,
    "difficulty" text NOT NULL,
    "token" text,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

--
-- ACTION ALTER TABLE
--
ALTER TABLE "room" ADD COLUMN "packId" bigint;
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "pack_question"
    ADD CONSTRAINT "pack_question_fk_0"
    FOREIGN KEY("packId")
    REFERENCES "question_pack"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "room"
    ADD CONSTRAINT "room_fk_0"
    FOREIGN KEY("packId")
    REFERENCES "question_pack"("id")
    ON DELETE SET NULL
    ON UPDATE NO ACTION;

--
-- MIGRATION VERSION FOR quiz_night
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('quiz_night', '20261026081534752', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261026081534752', "timestamp" = now();

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
