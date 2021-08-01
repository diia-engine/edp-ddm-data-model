CREATE OR REPLACE PROCEDURE p_raise_notice(p_string_to_log TEXT)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
--  RAISE NOTICE '%', p_string_to_log;
END;
$procedure$
SECURITY DEFINER
SET search_path = public, pg_temp;
