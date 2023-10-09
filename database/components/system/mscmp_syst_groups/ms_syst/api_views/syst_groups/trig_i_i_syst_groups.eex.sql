CREATE OR REPLACE FUNCTION ms_syst.trig_i_i_syst_groups()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_groups.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_groups/ms_syst/api_views/syst_groups/trig_i_i_syst_groups.eex.sql
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

    INSERT INTO ms_syst_data.syst_groups
        ( internal_name
        , display_name
        , external_name
        , parent_group_id
        , group_type_item_id
        , syst_description
        , user_description
        , syst_defined
        , user_maintainable )
    VALUES
        ( new.internal_name
        , new.display_name
        , new.external_name
        , new.parent_group_id
        , new.group_type_item_id
        , '(System Description Not Available)'
        , new.user_description
        , FALSE
        , TRUE )
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_i_syst_groups()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_groups() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_groups() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_i_syst_groups() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_groups API View for INSERT operations.$DOC$;
