--
-- pgmailer deploy script
--

--------------------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS pgmailer;
GRANT USAGE ON SCHEMA pgmailer TO pgmailer_sender;
--------------------------------------------------------------------------------

-- functional


\ir outmsg/before_action.sql
\ir outmsg/after_action.sql

\ir sender/complete.sql
\ir sender/error.sql
\ir sender/take.sql

\ir send.sql
\ir version.sql

-- updates

\ir updates/update--001.sql
