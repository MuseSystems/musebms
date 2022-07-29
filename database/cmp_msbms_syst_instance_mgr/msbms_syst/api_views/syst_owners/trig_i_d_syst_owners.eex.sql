CREATE OR REPLACE FUNCTION msbms_syst.trig_i_d_syst_owners()
RETURNS trigger AS
$BODY$

-- File:        trig_i_d_syst_owners.eex.sql
-- Location:    musebms/database/cmp_msbms_syst_instance_mgr/msbms_syst/api_views/syst_owners/trig_i_d_syst_owners.eex.sql
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
        exists( SELECT
                    TRUE
                FROM msbms_syst_data.syst_enum_functional_types seft
                WHERE
                      seft.enum_id = old.owner_state_id
                  AND seft.internal_name != 'owner_states_purge_eligible' )
    THEN

        RAISE EXCEPTION
            USING
                MESSAGE = 'You cannot delete an owner that is not in a purge ' ||
                          'eligible owner state using this API view.',
                DETAIL = msbms_syst_priv.get_exception_details(
                             p_proc_schema    => 'msbms_syst'
                            ,p_proc_name      => 'trig_i_d_syst_owners'
                            ,p_exception_name => 'invalid_api_view_call'
                            ,p_errcode        => 'PM008'
                            ,p_param_data     => to_jsonb(old)
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

    DELETE FROM msbms_syst_data.syst_owners WHERE id = old.id RETURNING * INTO old;

    RETURN old;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO msbms_syst, pg_temp;

ALTER FUNCTION msbms_syst.trig_i_d_syst_owners()
    OWNER TO <%= msbms_owner %>;

REVOKE EXECUTE ON FUNCTION msbms_syst.trig_i_d_syst_owners() FROM public;

COMMENT ON FUNCTION msbms_syst.trig_i_d_syst_owners() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_owners API View for DELETE operations.$DOC$;
