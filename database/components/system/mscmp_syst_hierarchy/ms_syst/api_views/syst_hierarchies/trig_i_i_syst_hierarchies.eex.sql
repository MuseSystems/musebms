CREATE OR REPLACE FUNCTION ms_syst.trig_i_i_syst_hierarchies()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_hierarchies.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_hierarchy/ms_syst/api_views/syst_hierarchies/trig_i_i_syst_hierarchies.eex.sql
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

    INSERT INTO ms_syst_data.syst_hierarchies
        ( internal_name
        , display_name
        , hierarchy_type_id
        , hierarchy_state_id
        , syst_defined
        , user_maintainable
        , structured
        , syst_description
        , user_description )
    VALUES
        ( new.internal_name
        , new.display_name
        , new.hierarchy_type_id
        , new.hierachy_state_id
        , FALSE
        , TRUE
        , coalesce(new.structured, TRUE)
        , '(System Description Not Available)'
        , new.user_description )
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_appl, pg_temp;

ALTER FUNCTION ms_syst.trig_i_i_syst_hierarchies()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_hierarchies() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_hierarchies() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_i_syst_hierarchies() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_hierarchies API View for INSERT operations.$DOC$;
