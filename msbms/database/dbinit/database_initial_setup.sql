-- File:        database_initial_setup.sql
-- Location:    msbms/priv/database/dbinit/database_initial_setup.sql
-- Project:     msbms
--
-- Licensed to Lima Buttgereit Holdings LLC (d/b/a Muse Systems) under one or
-- more agreements.  Muse Systems licenses this file to you under the terms and
-- conditions of your Muse Systems Master Services Agreement or governing
-- Statement of Work.
--
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  : : https: //muse.systems

/****
  This script initializes a fresh installation of the Muse Systems Business
  Management System.

  This script will create the required database roles and extensions in the
  target database cluster/database.  As such this script must be run as a
  superuser.

  Please be use that the following extensions are available to be installed
  prior to running this script:

    - uuid-ossp


****/


DO
$SCRIPT$
BEGIN
    RAISE EXCEPTION 'This should kill the CI process in an error condition.';
    --
    -- Database Cluster Preparation & Application Roles
    --

    IF
        NOT EXISTS(SELECT true FROM pg_roles WHERE rolname = 'msbms_owner')
    THEN

        CREATE ROLE msbms_owner;

        COMMENT ON ROLE msbms_owner IS
        $DOC$MSBMS Maximum Privilege System Account$DOC$;

    END IF;

    IF
        NOT EXISTS(SELECT true FROM pg_roles WHERE rolname = 'msbms_app_admin')
    THEN

        CREATE ROLE msbms_app_admin LOGIN;

        COMMENT ON ROLE msbms_app_admin IS
        $DOC$MSBMS Administrative Access Login Account$DOC$;

    END IF;

    IF
        NOT EXISTS(SELECT true FROM pg_roles WHERE rolname = 'msbms_app_user')
    THEN

        CREATE ROLE msbms_app_user LOGIN;

        COMMENT ON ROLE msbms_app_user IS
        $DOC$MSBMS Normal Application Access Login Account$DOC$;

    END IF;

    IF
        NOT EXISTS(SELECT true FROM pg_roles WHERE rolname = 'msbms_api_admin')
    THEN

        CREATE ROLE msbms_api_admin LOGIN;

        COMMENT ON ROLE msbms_api_admin IS
        $DOC$MSBMS Administrative API Access Login Account$DOC$;

    END IF;

    IF
        NOT EXISTS(SELECT true FROM pg_roles WHERE rolname = 'msbms_api_user')
    THEN

        CREATE ROLE msbms_api_user LOGIN;

        COMMENT ON ROLE msbms_app_user IS
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

    EXECUTE format('ALTER DATABASE %1$I OWNER TO msbms_owner'
                   ,current_database());

    SET SESSION AUTHORIZATION msbms_owner;
END;
$SCRIPT$;
