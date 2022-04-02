-- File:        database_initial_setup.eex.sql
-- Location:    database\app_msbms_global\gen_dbinit\database_initial_setup.eex.sql
-- Project:     Muse Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

/****
  This script initializes a fresh global instance management database for the
  Muse Systems Business Management System.

  This script will create the required extensions in the target database
  cluster/database.

  Please be use that the following extensions are available to be installed
  prior to running this script:

    - uuid-ossp
    - pgcrypto
****/

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pgcrypto;
