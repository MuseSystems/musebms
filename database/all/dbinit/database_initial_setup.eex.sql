-- File:        database_initial_setup.eex.sql
-- Location:    musebms/database/all/dbinit/database_initial_setup.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
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

  Please be sure that the following extensions are available to be installed
  prior to running this script:

    - uuid-ossp


****/


DO
$SCRIPT$
BEGIN

    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
    CREATE EXTENSION IF NOT EXISTS pgcrypto;

    -- Temporary UUIDv7 extension
    --
    -- !!!!! Do not release to production !!!!!
    --
    -- TODO: Remove from code at PostgreSQL 17 release.  PostgreSQL 17 is
    --       expected to have UUIDv7 support.

    IF
        exists( SELECT TRUE
                FROM pg_available_extensions
                WHERE name = 'pg_uuidv7' )
    THEN
        CREATE EXTENSION IF NOT EXISTS pg_uuidv7;
    ELSE
        CREATE OR REPLACE FUNCTION public.uuid_generate_v7( )
            RETURNS uuid AS
        $BODY$ SELECT PUBLIC.uuid_generate_v1mc();
            $BODY$
            LANGUAGE sql;
    END IF;

    REVOKE ALL ON SCHEMA public FROM public;
END;
$SCRIPT$;
