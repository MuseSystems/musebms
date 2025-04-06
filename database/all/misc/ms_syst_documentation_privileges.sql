-- File:        ms_syst_documentation_privileges.sql
-- Location:    musebms/database/all/misc/ms_syst_documentation_privileges.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

DO
$DOC_USER_GRANTS$
BEGIN
    IF
        EXISTS (SELECT TRUE
                FROM information_schema.schemata
                WHERE schema_name = 'ms_syst')
    THEN
        GRANT USAGE ON SCHEMA ms_syst TO ms_syst_documentation;
    END IF;

    IF
        EXISTS (SELECT TRUE
                FROM information_schema.schemata
                WHERE schema_name = 'ms_syst_priv')
    THEN
        GRANT USAGE ON SCHEMA ms_syst_priv TO ms_syst_documentation;
    END IF;

    IF
        EXISTS (SELECT TRUE
                FROM information_schema.schemata
                WHERE schema_name = 'ms_syst_data')
    THEN
        GRANT USAGE ON SCHEMA ms_syst_data TO ms_syst_documentation;
    END IF;

    IF
        EXISTS (SELECT TRUE
                FROM information_schema.schemata
                WHERE schema_name = 'ms_appl')
    THEN
        GRANT USAGE ON SCHEMA ms_appl TO ms_syst_documentation;
    END IF;

    IF
        EXISTS (SELECT TRUE
                FROM information_schema.schemata
                WHERE schema_name = 'ms_appl_priv')
    THEN
        GRANT USAGE ON SCHEMA ms_appl_priv TO ms_syst_documentation;
    END IF;

    IF
        EXISTS (SELECT TRUE
                FROM information_schema.schemata
                WHERE schema_name = 'ms_appl_data')
    THEN
        GRANT USAGE ON SCHEMA ms_appl_data TO ms_syst_documentation;
    END IF;
END;
$DOC_USER_GRANTS$;
