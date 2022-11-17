-- File:        no_changes.eex.sql
-- Location:    musebms/database/all/misc/no_changes.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

RAISE NOTICE
    USING MESSAGE = format( '*** No changes for migration version %1$s.',
                            '<%= ms_migration_version %>');
