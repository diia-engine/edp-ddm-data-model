CREATE OR REPLACE FUNCTION f_edrpou_is_correct(char(10))
 RETURNS BOOLEAN
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN true;
END;
$function$
SECURITY DEFINER
SET search_path = public, pg_temp;
