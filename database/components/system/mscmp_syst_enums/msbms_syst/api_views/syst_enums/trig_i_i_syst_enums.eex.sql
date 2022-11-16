CREATE OR REPLACE FUNCTION msbms_syst.trig_i_i_syst_enums()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_enums.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_enums/msbms_syst/api_views/syst_enums/trig_i_i_syst_enums.eex.sql
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

    INSERT INTO msbms_syst_data.syst_enums
        ( internal_name
        , display_name
        , syst_description
        , user_description
        , syst_defined
        , user_maintainable
        , default_user_options )
    VALUES
        ( new.internal_name
        , new.display_name
        , '(System Description Not Available)'
        , new.user_description
        , FALSE
        , TRUE
        , new.default_user_options )
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO msbms_syst, pg_temp;

ALTER FUNCTION msbms_syst.trig_i_i_syst_enums()
    OWNER TO <%= msbms_owner %>;

REVOKE EXECUTE ON FUNCTION msbms_syst.trig_i_i_syst_enums() FROM public;

COMMENT ON FUNCTION msbms_syst.trig_i_i_syst_enums() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_enums API View for INSERT operations.$DOC$;
