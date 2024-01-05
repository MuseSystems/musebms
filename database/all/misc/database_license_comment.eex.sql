-- File:        database_license_comment.eex.sql
-- Location:    musebms/database/all/misc/database_license_comment.eex.sql
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
$DOCUMENTATION$
DECLARE
    var_current_database text := current_database();

    var_comment_text text :=
$LICENSE$
__Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems__

This database software and documentation is licensed to you under the terms of the
[Muse Systems Business Management System License Agreement v1.1](https://docs.muse.systems/license/)
or other written, superseding license that you have obtained from Muse Systems.

Only Muse Systems may license this software to you.  Your continued use of this
software indicates your agreement to abide by the applicable license terms.

This database may include content copyrighted by and licensed from third
parties.

Please see the license or contact us for more information.

[muse.information@musesystems.com](mailto:muse.information@musesystems.com) :: [https://muse.systems](https://muse.systems)
$LICENSE$;
BEGIN

    EXECUTE format(
        'COMMENT ON DATABASE %1$I IS %2$L;',
        var_current_database,
        var_comment_text);

END;
$DOCUMENTATION$;
