
-- Source File: no_changes.eex.sql
-- Location:    msbms/database/common/misc/no_changes.eex.sql
-- Project:     musebms
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
                            '<%= msbms_migration_version %>');
