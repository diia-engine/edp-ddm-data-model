CREATE OR REPLACE PROCEDURE p_grant_analytics_user(p_user_name text)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
  c_obj_pattern TEXT := 'report%v';
  r RECORD;
BEGIN
  FOR r IN SELECT * FROM information_schema.views WHERE table_name LIKE c_obj_pattern AND table_schema = 'public' LOOP
    EXECUTE 'GRANT SELECT ON ' || r.table_name || ' TO ' || p_user_name || ';';
  END LOOP;
 END;
$procedure$
SECURITY DEFINER
SET search_path = public, pg_temp;
