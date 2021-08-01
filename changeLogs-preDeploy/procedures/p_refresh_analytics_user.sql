CREATE OR REPLACE PROCEDURE p_refresh_analytics_user(p_user_name TEXT, p_user_pwd TEXT)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
  EXECUTE 'DROP ROLE IF EXISTS ' || p_user_name || ';';
  EXECUTE 'CREATE ROLE ' || p_user_name || ' LOGIN PASSWORD ''' || p_user_pwd || ''';';
  CALL p_grant_analytics_user(p_user_name);
 END;
$procedure$
SECURITY DEFINER
SET search_path = public, pg_temp;
