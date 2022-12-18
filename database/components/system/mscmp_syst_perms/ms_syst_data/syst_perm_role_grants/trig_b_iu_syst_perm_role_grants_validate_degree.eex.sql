CREATE OR REPLACE FUNCTION ms_syst_data.trig_b_iu_syst_perm_role_grants_validate_degree()
RETURNS trigger AS
$BODY$

-- File:        trig_b_iu_syst_perm_role_grants_validate_degree.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_perms/ms_syst_data/syst_perm_role_grants/trig_b_iu_syst_perm_role_grants_validate_degree.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

BEGIN

    IF
        NOT exists(
                SELECT TRUE
                FROM
                    ms_syst_data.syst_perms p
                        JOIN ms_syst_data.syst_perm_type_degrees ptd
                             ON ptd.perm_type_id = p.perm_type_id
                WHERE p.id = new.perm_id AND ptd.id = new.perm_type_degree_id )
    THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'The permission degree value must be associated ' ||
                          'with the permission type assigned to the ' ||
                          'permission being granted.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst'
                            ,p_proc_name      => 'trig_b_iu_syst_perm_role_grants_validate_degree'
                            ,p_exception_name => 'invalid_api_view_call'
                            ,p_errcode        => 'PM008'
                            ,p_param_data     => to_jsonb(new)
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

    RETURN new;

END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION ms_syst_data.trig_b_iu_syst_perm_role_grants_validate_degree()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_data.trig_b_iu_syst_perm_role_grants_validate_degree() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_data.trig_b_iu_syst_perm_role_grants_validate_degree() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst_data.trig_b_iu_syst_perm_role_grants_validate_degree() IS
$DOC$Validates that the assigned syst_perm_role_grants.perm_type_degree_id value is
valid for the permission's type.$DOC$;
