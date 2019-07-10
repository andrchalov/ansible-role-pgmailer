--
-- PGMAILER
-- update--002.sql
--

SELECT pgmailer.version() = '0.0.1' AS pgmailer_update_002;
\gset

\if :pgmailer_update_002

--------------------------------------------------------------------------------
ALTER TABLE pgmailer.outmsg ADD COLUMN reply_email pgmailer.email;
ALTER TABLE pgmailer.outmsg ADD COLUMN reply_name text;
--------------------------------------------------------------------------------

COMMENT ON SCHEMA pgmailer IS '0.0.2';

\endif
