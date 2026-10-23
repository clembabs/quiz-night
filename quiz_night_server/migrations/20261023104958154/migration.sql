BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "room" ADD COLUMN "startedAt" timestamp without time zone;
ALTER TABLE "room" ADD COLUMN "lastActivityAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE "room" ADD COLUMN "endReason" text;

--
-- MIGRATION VERSION FOR quiz_night
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('quiz_night', '20261023104958154', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261023104958154', "timestamp" = now();

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
