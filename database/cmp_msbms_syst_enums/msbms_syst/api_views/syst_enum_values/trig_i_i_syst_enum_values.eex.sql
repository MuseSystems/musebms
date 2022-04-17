CREATE OR REPLACE FUNCTION msbms_syst.trig_i_i_syst_enum_values()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_enum_values.eex.sql
-- Location:    database\cmp_msbms_syst_enums\msbms_syst\api_views\syst_enum_values\trig_i_i_syst_enum_values.eex.sql
-- Project:     Muse Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

BEGIN

    INSERT INTO msbms_syst_data.syst_enum_values
        ( internal_name
        , display_name
        , external_name
        , enum_id
        , functional_type_id
        , enum_default
        , functional_type_default
        , syst_defined
        , user_maintainable
        , syst_description
        , user_description
        , sort_order
        , user_options )
    VALUES
        ( new.internal_name
        , new.display_name
        , new.external_name
        , new.enum_id
        , new.functional_type_id
        , new.enum_default
        , new.functional_type_default
        , FALSE
        , TRUE
        , '(System Description Not Available)'
        , new.user_description
        , new.sort_order
        , new.user_options )
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION msbms_syst.trig_i_i_syst_enum_values()
    OWNER TO <%= msbms_owner %>;

REVOKE EXECUTE ON FUNCTION msbms_syst.trig_i_i_syst_enum_values() FROM public;
GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_i_syst_enum_values() TO <%= msbms_owner %>;
GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_i_syst_enum_values() TO <%= msbms_apiusr %>;

COMMENT ON FUNCTION msbms_syst.trig_i_i_syst_enum_values() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_enum_values API View for INSERT operations.$DOC$;
