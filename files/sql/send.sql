--
-- pgmailer.send()
--

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pgmailer.send(
  a_from_email text,
  a_from_name text,
  a_to_email text,
  a_to_name text,
  a_subject text,
  a_body_text text,
  a_body_html text,
  a_trackuid text,
  a_priority smallint DEFAULT 0
)
  RETURNS void
  LANGUAGE plpgsql
AS $function$
DECLARE

BEGIN

END;
$function$;
-------------------------------------------------------------------------------
