
/************************************************************************************************

  Full Record Version

 ************************************************************************************************/

CREATE OR REPLACE FUNCTION
    ms_appl_priv.is_hierarchy_config_valid(p_hierarchy ms_appl_data.conf_hierarchies)
RETURNS boolean AS
$BODY$

-- File:        is_hierarchy_config_valid.eex.sql
-- Location:    musebms/database/components/application/mscmp_core_hierarchy/ms_appl_priv/functions/is_hierarchy_config_valid.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

SELECT array_length(ms_appl_priv.hierarchy_config_check(p_hierarchy), 1) = 0;

$BODY$
LANGUAGE sql STABLE;

ALTER FUNCTION
    ms_appl_priv.is_hierarchy_config_valid(p_hierarchy ms_appl_data.conf_hierarchies)
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION
    ms_appl_priv.is_hierarchy_config_valid(p_hierarchy ms_appl_data.conf_hierarchies)
    FROM public;

GRANT EXECUTE ON FUNCTION
    ms_appl_priv.is_hierarchy_config_valid(p_hierarchy ms_appl_data.conf_hierarchies)
    TO <%= ms_owner %>;

COMMENT ON FUNCTION
    ms_appl_priv.is_hierarchy_config_valid(p_hierarchy ms_appl_data.conf_hierarchies)
    IS
$DOC$Validates that a Hierarchy record and its associated Hierarchy Item records are
consistent and ready for use by Hierarchy implementing Components.  Returns
`TRUE` if Hierarchy is valid and may be set to an "active" state; returns false
otherwise.$DOC$;

/************************************************************************************************

  Simple Record ID Version

 ************************************************************************************************/

CREATE OR REPLACE FUNCTION ms_appl_priv.is_hierarchy_config_valid(p_hierarchy_id uuid)
RETURNS boolean AS
$BODY$

-- File:        is_hierarchy_config_valid.eex.sql
-- Location:    musebms/database/components/application/mscmp_core_hierarchy/ms_appl_priv/functions/is_hierarchy_config_valid.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

SELECT array_length(ms_appl_priv.hierarchy_config_check(p_hierarchy_id), 1) = 0;

$BODY$
LANGUAGE sql STABLE;

ALTER FUNCTION ms_appl_priv.is_hierarchy_config_valid(p_hierarchy_id uuid)
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION
    ms_appl_priv.is_hierarchy_config_valid(p_hierarchy_id uuid)
    FROM public;

GRANT EXECUTE ON FUNCTION
    ms_appl_priv.is_hierarchy_config_valid(p_hierarchy_id uuid)
    TO <%= ms_owner %>;

COMMENT ON FUNCTION
    ms_appl_priv.is_hierarchy_config_valid(p_hierarchy_id uuid)
    IS
$DOC$Validates that a Hierarchy record and its associated Hierarchy Item records are
consistent and ready for use by Hierarchy implementing Components.  Returns
`TRUE` if Hierarchy is valid and may be set to an "active" state; returns false
otherwise.$DOC$;
