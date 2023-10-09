CREATE OR REPLACE FUNCTION ms_syst.trig_i_i_syst_group_types()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_group_types.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_groups/ms_syst/api_views/syst_group_types/trig_i_i_syst_group_types.eex.sql
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

    INSERT INTO ms_syst_data.syst_group_types
        ( internal_name
        , display_name
        , functional_type_id
        , syst_defined
        , user_maintainable
        , syst_description
        , user_description )
    VALUES
        ( new.internal_name
        , new.display_name
        , new.functional_type_id
        , FALSE
        , TRUE
        , '(System Description Not Available)'
        , new.user_description )
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_i_syst_group_types()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_group_types() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_group_types() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_i_syst_group_types() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_enum_items API View for INSERT operations.$DOC$;