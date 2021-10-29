
-- Source File: database_initial_setup.eex.sql
-- Location:    msbms/database/instance/dbinit/database_initial_setup.eex.sql
-- Project:     musebms
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from thrid parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

/****
  This script initializes a fresh installation of the Muse Systems Business
  Management System.

  This script will create the required database roles and extensions in the
  target database cluster/database.

  Please be use that the following extensions are available to be installed
  prior to running this script:

    - uuid-ossp


****/


DO
$SCRIPT$
BEGIN

    --
    -- Database Cluster Preparation & Application Roles
    --

    IF
        NOT EXISTS(SELECT true FROM pg_roles WHERE rolname = '<%= msbms_owner %>')
    THEN

        CREATE ROLE <%= msbms_owner %>;

        COMMENT ON ROLE <%= msbms_owner %> IS
        $DOC$MSBMS Maximum Privilege System Account$DOC$;

    END IF;

    IF
        NOT EXISTS(SELECT true FROM pg_roles WHERE rolname = '<%= msbms_app_admin %>')
    THEN

        CREATE ROLE <%= msbms_app_admin %> LOGIN;

        COMMENT ON ROLE <%= msbms_app_admin %> IS
        $DOC$MSBMS Administrative Access Login Account$DOC$;

    END IF;

    IF
        NOT EXISTS(SELECT true FROM pg_roles WHERE rolname = '<%= msbms_app_user %>')
    THEN

        CREATE ROLE <%= msbms_app_user %> LOGIN;

        COMMENT ON ROLE <%= msbms_app_user %> IS
        $DOC$MSBMS Normal Application Access Login Account$DOC$;

    END IF;

    IF
        NOT EXISTS(SELECT true FROM pg_roles WHERE rolname = '<%= msbms_api_admin %>')
    THEN

        CREATE ROLE <%= msbms_api_admin %> LOGIN;

        COMMENT ON ROLE <%= msbms_api_admin %> IS
        $DOC$MSBMS Administrative API Access Login Account$DOC$;

    END IF;

    IF
        NOT EXISTS(SELECT true FROM pg_roles WHERE rolname = '<%= msbms_api_user %>')
    THEN

        CREATE ROLE <%= msbms_api_user %> LOGIN;

        COMMENT ON ROLE <%= msbms_app_user %> IS
        $DOC$MSBMS Normal API Access Login Account$DOC$;

    END IF;

    --
    -- Application Database Preparation
    --

    IF
        current_database()::text IN ('postgres'
                                    ,'template1'
                                    ,'template0')
    THEN
        RAISE EXCEPTION
            USING MESSAGE =
                'You may not use this script while connected to one ' ||
                'of the system databases.';
    END IF;


    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
    CREATE EXTENSION IF NOT EXISTS "pgcrypto";

    EXECUTE format('ALTER DATABASE %1$I OWNER TO <%= msbms_owner %>'
                   ,current_database());

    SET SESSION AUTHORIZATION <%= msbms_owner %>;
END;
$SCRIPT$;
