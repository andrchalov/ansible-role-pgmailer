--
-- pgmailer.outmsg_before_action()
--

--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pgmailer.outmsg_before_action()
  RETURNS trigger
  LANGUAGE plpgsql
AS
$function$
BEGIN
  IF TG_OP = 'UPDATE' THEN
    IF NEW.locked NOTNULL AND NEW.locked IS DISTINCT FROM OLD.locked THEN
      NEW.sendattempts = NEW.sendattempts + 1;
    END IF;
  END IF;

  NEW.state =
    CASE
      WHEN NEW.readed NOTNULL
        THEN 'readed'
      WHEN NEW.sended NOTNULL
        THEN 'sended'
      WHEN NEW.locked NOTNULL AND NEW.locked > now() - interval '1 min'
        THEN 'locked'
      WHEN NEW.sendattempts > 3
        THEN 'failed'
      WHEN NEW.locked > (now() - (interval '1 min' * NEW.sendattempts))
        THEN 'waiting'
      ELSE
        'queued'
    END::pgmailer.outmsg_state;

	RETURN NEW;
END;
$function$;
--------------------------------------------------------------------------------
