--
-- PGMAILER
-- update--001.sql
--

SELECT pgmailer.version() ISNULL AS pgmailer_update_001;
\gset

\if :pgmailer_update_001

--------------------------------------------------------------------------------
CREATE DOMAIN pgmailer.email AS varchar(128);
ALTER DOMAIN pgmailer.email
  ADD CONSTRAINT email_check
    CHECK (VALUE::text ~ '^[a-z0-9._%\-\+]+@[a-z0-9.-]+\.[a-z]+$'::text);
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
CREATE TYPE pgmailer.outmsg_state AS
  ENUM (
    'waiting',
    'queued',
    'locked',
    'sended',
    'failed',
    'readed'
  );
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS pgmailer.outmsg(
  id bigserial NOT NULL,
  mo timestamp with time zone NOT NULL DEFAULT now(),
  priority smallint NOT NULL DEFAULT 0,

  from_email pgmailer.email NOT NULL,
  from_name text NOT NULL DEFAULT '',
  to_email pgmailer.email NOT NULL,
  to_name text NOT NULL DEFAULT '',

  subject text NOT NULL,
  body_text text NOT NULL,
  body_html text,

  trackuid bigint,       -- tracking uid уникальный идентификатор письма для
                         -- отслеживания факта прочтения, устанавливается
                         -- извне

  sendattempts smallint NOT NULL DEFAULT 0,
  errlog text[],

  locked timestamp with time zone,
  sended timestamp with time zone,
  readed timestamp with time zone,

  state pgmailer.outmsg_state NOT NULL,

  CONSTRAINT outmsg_pkey PRIMARY KEY (id),
  CONSTRAINT outmsg_ukey0 UNIQUE (trackuid),
  CONSTRAINT outmsg_chk0 CHECK (sendattempts >= 0)
);
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
CREATE INDEX outmsg_idx0
  ON pgmailer.outmsg (state, priority, mo);
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
CREATE INDEX outmsg_idx1
  ON pgmailer.outmsg (trackuid);
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
CREATE TRIGGER before_action
  BEFORE INSERT OR UPDATE
  ON pgmailer.outmsg
  FOR EACH ROW
  EXECUTE PROCEDURE pgmailer.outmsg_before_action();
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
CREATE TRIGGER after_action
  AFTER INSERT OR UPDATE
  ON pgmailer.outmsg
  FOR EACH ROW
  EXECUTE PROCEDURE pgmailer.outmsg_after_action();
--------------------------------------------------------------------------------



COMMENT ON SCHEMA pgmailer IS '0.0.1';

\endif
