
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pgmailer.version()
  RETURNS text
  LANGUAGE sql
AS $function$
SELECT pg_catalog.obj_description(oid, 'pg_namespace')
  FROM pg_catalog.pg_namespace
  WHERE nspname = 'pgmailer';
$function$;
-------------------------------------------------------------------------------
