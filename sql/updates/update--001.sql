--
-- PGMAILER
-- update--001.sql
--

CREATE SCHEMA _pgmailer AUTHORIZATION :"schema_owner";

--------------------------------------------------------------------------------
CREATE DOMAIN _pgmailer.email AS varchar(128);
ALTER DOMAIN _pgmailer.email
  ADD CONSTRAINT email_check
    CHECK (VALUE::text ~ '^[a-z0-9._%\-\+]+@[a-z0-9.-]+\.[a-z]+$'::text);
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
CREATE TABLE _pgmailer.outmsg(
  id serial NOT NULL,
  mo timestamptz NOT NULL DEFAULT now(),
  priority smallint NOT NULL DEFAULT 0,

  from_email _pgmailer.email NOT NULL,
  from_name text NOT NULL DEFAULT '',
  to_email _pgmailer.email NOT NULL,
  to_name text NOT NULL DEFAULT '',
  reply_email _pgmailer.email,
  reply_name text,

  subject text NOT NULL,
  body_text text NOT NULL,
  body_html text,

  trackuid bigint,       -- tracking uid уникальный идентификатор письма для
                         -- отслеживания факта прочтения, устанавливается
                         -- извне
  customdata hstore,
  sendattempts smallint NOT NULL DEFAULT 0,
  errlog text[],

  locked timestamptz,
  sended timestamptz,
  readed timestamptz,

  state text NOT NULL,

  CONSTRAINT outmsg_pkey PRIMARY KEY (id),
  CONSTRAINT outmsg_ukey0 UNIQUE (trackuid),
  CONSTRAINT outmsg_chk0 CHECK (sendattempts >= 0),
  CONSTRAINT outmsg_chk1 CHECK (state = ANY ('{waiting,queued,locked,sended,failed,readed}'))
);
ALTER TABLE _pgmailer.outmsg OWNER TO :"schema_owner";
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
CREATE INDEX outmsg_idx0
  ON _pgmailer.outmsg (state, priority, mo);
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
CREATE INDEX outmsg_idx1
  ON _pgmailer.outmsg (trackuid);
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
CREATE INDEX outmsg_idx2
  ON _pgmailer.outmsg USING GIST (customdata);
--------------------------------------------------------------------------------
