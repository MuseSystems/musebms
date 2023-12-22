-- File:        comments_apiview_update_modes.eex.sql
-- Location:    musebms/database/all/ms_syst_priv/types/comments_apiview_update_modes.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TYPE ms_syst_priv.comments_apiview_update_modes AS ENUM
    ('always', 'maint', 'never');

COMMENT ON TYPE ms_syst_priv.comments_apiview_update_modes IS
$DOC$#### Private Enum `ms_syst_priv.comments_apiview_update_modes`

Establishes the available values for the API View Column update modes for system
defined data.

#### Available Values

  * `always` - indicates that the column is always updatable for system defined
    data, even if the data is not marked "user maintainable".

  * `maint` - indicates that the column is only updatable if the system defined
    data is marked as user maintainable.

  * `never` - indicates that the column is not updatable under any circumstances
    when the data is system defined.
$DOC$;
