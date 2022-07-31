CREATE OR REPLACE FUNCTION msbms_syst.trig_i_u_syst_access_account_instance_assocs()
RETURNS trigger AS
$BODY$

-- File:        trig_i_u_syst_access_account_instance_assocs.eex.sql
-- Location:    musebms/database/cmp_msbms_syst_authentication/msbms_syst/api_views/syst_access_account_instance_assocs/trig_i_u_syst_access_account_instance_assocs.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

BEGIN

    IF
        new.access_account_id  != old.access_account_id OR
        new.credential_type_id != old.credential_type_id OR
        new.instance_id        != old.instance_id
    THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'The requested data update included changes to fields disallowed ' ||
                          'by the business rules of the API View.',
                DETAIL = msbms_syst_priv.get_exception_details(
                             p_proc_schema    => 'msbms_syst'
                            ,p_proc_name      => 'trig_i_u_syst_access_account_instance_assocs'
                            ,p_exception_name => 'invalid_api_view_call'
                            ,p_errcode        => 'PM008'
                            ,p_param_data     => jsonb_build_object('new', new, 'old', old)
                            ,p_context_data   =>
                                jsonb_build_object(
                                     'tg_op',         tg_op
                                    ,'tg_when',       tg_when
                                    ,'tg_schema',     tg_table_schema
                                    ,'tg_table_name', tg_table_name)),
                ERRCODE = 'PM008',
                SCHEMA = tg_table_schema,
                TABLE = tg_table_name;
    END IF;

    UPDATE msbms_syst_data.syst_access_account_instance_assocs
    SET
        access_granted      = new.access_granted
      , invitation_issued   = new.invitation_issued
      , invitation_expires  = new.invitation_expires
      , invitation_declined = new.invitation_declined
    WHERE id = new.id
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO msbms_syst, pg_temp;

ALTER FUNCTION msbms_syst.trig_i_u_syst_access_account_instance_assocs()
    OWNER TO <%= msbms_owner %>;

REVOKE EXECUTE ON FUNCTION msbms_syst.trig_i_u_syst_access_account_instance_assocs() FROM public;
GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_u_syst_access_account_instance_assocs() TO <%= msbms_owner %>;

COMMENT ON FUNCTION msbms_syst.trig_i_u_syst_access_account_instance_assocs() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_access_account_instance_assocs API View for UPDATE operations.$DOC$;
