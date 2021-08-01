CREATE OR REPLACE PROCEDURE public.p_format_sys_columns(p_sys_key_val hstore, INOUT op_sys_hist hstore, INOUT op_sys_rcnt hstore)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
  l_curr_time TIMESTAMPTZ;
  --
  l_curr_user TEXT;
  l_source_system TEXT;
  l_source_application TEXT;
  l_source_process TEXT;
  l_source_business_process_definition_id TEXT;
  l_source_business_process_instance_id TEXT;
  l_source_business_activity TEXT;
  l_source_business_activity_instance_id TEXT;
  l_digital_sign TEXT;
  l_digital_sign_derived TEXT;
  l_digital_sign_checksum TEXT;
  l_digital_sign_derived_checksum TEXT;
  --
  l_source_system_id UUID;
  l_source_application_id UUID;
  l_source_process_id UUID;
BEGIN
  --
  IF NOT (p_sys_key_val ? 'curr_user') THEN
    RAISE EXCEPTION 'ERROR: Parameter "curr_user" doesn''t defined correctly' USING ERRCODE = '20001';
  END IF;
  --
  IF NOT (p_sys_key_val ? 'source_system') THEN
    RAISE EXCEPTION 'ERROR: Parameter "source_system" doesn''t defined correctly' USING ERRCODE = '20001';
  END IF;
  --
  IF NOT (p_sys_key_val ? 'source_application') THEN
    RAISE EXCEPTION 'ERROR: Parameter "source_application" doesn''t defined correctly' USING ERRCODE = '20001';
  END IF;
  --
  l_curr_time := now();
  l_curr_user := p_sys_key_val -> 'curr_user';
  --RAISE NOTICE '%, %', p_sys_key_val, l_curr_user;
  --
  l_source_system :=  p_sys_key_val -> 'source_system';
  l_source_application :=  p_sys_key_val -> 'source_application';
  l_source_process :=  p_sys_key_val -> 'source_process';
  l_source_business_process_definition_id := p_sys_key_val -> 'source_process_definition_id';
  l_source_business_process_instance_id := p_sys_key_val -> 'source_process_instance_id';
  l_source_business_activity := p_sys_key_val -> 'business_activity';
  l_source_business_activity_instance_id := p_sys_key_val -> 'source_activity_instance_id';
  --
  l_digital_sign :=  p_sys_key_val -> 'digital_sign';
  l_digital_sign_derived :=  p_sys_key_val -> 'digital_sign_derived';
  --
  l_digital_sign_checksum :=  p_sys_key_val -> 'ddm_digital_sign_checksum';
  l_digital_sign_derived_checksum :=  p_sys_key_val -> 'ddm_digital_sign_derived_checksum';
  --
  l_source_system_id :=  f_get_source_data_id('ddm_source_system','system_id','system_name',l_source_system,true,l_curr_user);
  l_source_application_id :=  f_get_source_data_id('ddm_source_application','application_id','application_name',l_source_application,true,l_curr_user);
  --
  IF l_source_process IS NOT NULL THEN
    l_source_process_id :=  f_get_source_data_id('ddm_source_business_process','business_process_id','business_process_name',l_source_process,true,l_curr_user);
  END IF;
  --
  op_sys_hist := (    'ddm_created_at=>"'     || l_curr_time::text       || '"'
                 || ', ddm_created_by=>"'     || l_curr_user             || '"'
                 || ', ddm_system_id=>"'      || l_source_system_id      || '"'
                 || ', ddm_application_id=>"' || l_source_application_id || '"'
                 || CASE WHEN l_source_process                        IS NOT NULL THEN ', ddm_business_process_id=>"'            || l_source_process_id                     || '"' ELSE '' END
                 || CASE WHEN l_source_business_process_definition_id IS NOT NULL THEN ', ddm_business_process_definition_id=>"' || l_source_business_process_definition_id || '"' ELSE '' END
                 || CASE WHEN l_source_business_process_instance_id   IS NOT NULL THEN ', ddm_business_process_instance_id=>"'   || l_source_business_process_instance_id   || '"' ELSE '' END
                 || CASE WHEN l_source_business_activity              IS NOT NULL THEN ', ddm_business_activity=>"'              || l_source_business_activity              || '"' ELSE '' END
                 || CASE WHEN l_source_business_activity_instance_id  IS NOT NULL THEN ', ddm_business_activity_instance_id=>"'  || l_source_business_activity_instance_id  || '"' ELSE '' END
                 || CASE WHEN l_digital_sign                          IS NOT NULL THEN ', ddm_digital_sign=>"'                   || l_digital_sign                          || '"' ELSE '' END
                 || CASE WHEN l_digital_sign_derived                  IS NOT NULL THEN ', ddm_digital_sign_derived=>"'           || l_digital_sign_derived                  || '"' ELSE '' END
                 || CASE WHEN l_digital_sign_checksum                 IS NOT NULL THEN ', ddm_digital_sign_checksum=>"'          || l_digital_sign_checksum                 || '"' ELSE '' END
                 || CASE WHEN l_digital_sign_derived_checksum         IS NOT NULL THEN ', ddm_digital_sign_derived_checksum=>"'  || l_digital_sign_derived_checksum         || '"' ELSE '' END
                 )::hstore;

  op_sys_rcnt := (    'ddm_created_at=>"' || l_curr_time::text || '"'
                 || ', ddm_created_by=>"' || l_curr_user       || '"'
                 || ', ddm_updated_at=>"' || l_curr_time::text || '"'
                 || ', ddm_updated_by=>"' || l_curr_user       || '"'
                 )::hstore;

  CALL p_raise_notice(op_sys_hist::text);
  CALL p_raise_notice(op_sys_rcnt::text);
END;
$procedure$
SECURITY DEFINER
SET search_path = public, pg_temp;
