
-- Source File: database_migrations.eex.sql
-- Location:    msbms/database/common/msbms_syst_data/seed_data/database_migrations.eex.sql
-- Project:     musebms
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from thrid parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

INSERT INTO msbms_syst_data.database_migrations
    (migration_sequence, migration_name)
VALUES
    (<%= starting_database_version %>, 'starting_database');
