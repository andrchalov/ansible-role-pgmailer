--
-- pgmailer deploy script
--

--------------------------------------------------------------------------------
CREATE SCHEMA pgmailer AUTHORIZATION :"schema_owner";
REVOKE ALL ON SCHEMA pgmailer FROM PUBLIC;
GRANT USAGE ON SCHEMA pgmailer TO pgmailer;
--------------------------------------------------------------------------------

SET SESSION AUTHORIZATION :"schema_owner";

\ir outmsg/__deploy.sql
\ir sender/__deploy.sql

RESET SESSION AUTHORIZATION;
