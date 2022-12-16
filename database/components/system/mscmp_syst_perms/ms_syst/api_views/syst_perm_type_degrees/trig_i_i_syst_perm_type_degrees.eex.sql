CREATE OR REPLACE FUNCTION ms_syst.trig_i_i_syst_perm_type_degrees()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_perm_type_degrees.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_perms/ms_syst/api_views/syst_perm_type_degrees/trig_i_i_syst_perm_type_degrees.eex.sql
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
        ( SELECT syst_defined
          FROM ms_syst_data.syst_perm_types
          WHERE id = new.perm_type_id )
    THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'You may not create new permission type degree ' ||
                          'records for system defined permission types ' ||
                          'using this API view.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst'
                            ,p_proc_name      => 'trig_i_i_syst_perm_type_degrees'
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

    INSERT INTO ms_syst_data.syst_perm_type_degrees
        (internal_name
        , display_name
        , external_name
        , perm_type_id
        , ordering
        , syst_description
        , user_description)
    VALUES
        (new.internal_name
        ,new.display_name
        ,new.external_name
        ,new.perm_type_id
        ,new.ordering
        ,'(System Description Not Available)'
        ,new.user_description)
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_i_syst_perm_type_degrees()
    OWNER TO <%= msbms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_perm_type_degrees() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_perm_type_degrees() TO <%= msbms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_i_syst_perm_type_degrees() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_perm_type_degrees API View for INSERT operations.$DOC$;
