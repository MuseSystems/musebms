/************************************************************************************************

  Full Record Version

 ************************************************************************************************/

CREATE OR REPLACE FUNCTION
    ms_appl_priv.hierarchy_config_check(p_hierarchy ms_appl_data.conf_hierarchies)
RETURNS text[] AS
$BODY$

-- File:        hierarchy_config_check.eex.sql
-- Location:    musebms/database/components/application/mscmp_core_hierarchy/ms_appl_priv/functions/hierarchy_config_check.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

DECLARE

    var_errors text[] := '{}'::text[];

BEGIN

    -- Handle unstructured hierarchies
    IF
        NOT p_hierarchy.structured
            AND exists( SELECT TRUE
                        FROM ms_appl_data.conf_hierarchy_items chi
                        WHERE chi.hierarchy_id = p_hierarchy.id )
    THEN
        var_errors := var_errors || 'unstructured_with_hierarchy_items'::text;
    END IF;

    -- Ensure that top level hierarchy item is required and that all hierarchy
    -- items between the highest and lowest level required item are also
    -- required.  This also indirectly tests that structured hierarchies have at
    -- least one defined Hierarchy Item record association.

    IF
        p_hierarchy.structured AND
            coalesce( ( SELECT NOT bool_and( required )
                        FROM ms_appl_data.conf_hierarchy_items chi
                        WHERE
                              chi.hierarchy_id = p_hierarchy.id
                          AND chi.hierarchy_depth <=
                                  ( SELECT hierarchy_depth
                                    FROM ms_appl_data.conf_hierarchy_items
                                    WHERE
                                          hierarchy_id = p_hierarchy.id
                                      AND required
                                    ORDER BY hierarchy_depth DESC
                                    LIMIT 1 ) ), TRUE )
    THEN
        var_errors := var_errors || 'structured_invalid_required_items'::text;
    END IF;

    -- Ensure that bottom level required hierarchy item allows leaf node
    -- references.

    IF
        p_hierarchy.structured
                AND ( SELECT NOT allow_leaf_nodes
                      FROM ms_appl_data.conf_hierarchy_items
                      WHERE
                            hierarchy_id = p_hierarchy.id
                        AND required
                      ORDER BY hierarchy_depth DESC
                      LIMIT 1 )
    THEN
        var_errors := var_errors || 'structured_invalid_allow_leaf_nodes'::text;
    END IF;

    RETURN var_errors;

END;
$BODY$
LANGUAGE plpgsql STABLE;

ALTER FUNCTION
    ms_appl_priv.hierarchy_config_check(p_hierarchy ms_appl_data.conf_hierarchies)
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION
    ms_appl_priv.hierarchy_config_check(p_hierarchy ms_appl_data.conf_hierarchies)
    FROM public;

GRANT EXECUTE ON FUNCTION
    ms_appl_priv.hierarchy_config_check(p_hierarchy ms_appl_data.conf_hierarchies)
    TO <%= ms_owner %>;

COMMENT ON FUNCTION
    ms_appl_priv.hierarchy_config_check(p_hierarchy ms_appl_data.conf_hierarchies)
    IS
$DOC$Checks a number of validity conditions which a Hierarchy and associated
Hierarchy Item records must meet prior to the Hierarchy being set to an "active"
state.

The function returns an array of text values indicating which of the validity
checks failed.  If no checks failed and the Hierarchy is valid, the returned
array will be empty.$DOC$;

/************************************************************************************************

  Simple Record ID Version

 ************************************************************************************************/

CREATE OR REPLACE FUNCTION ms_appl_priv.hierarchy_config_check(p_hierarchy_id uuid)
RETURNS text[] AS
$BODY$

-- File:        hierarchy_config_check.eex.sql
-- Location:    musebms/database/components/application/mscmp_core_hierarchy/ms_appl_priv/functions/hierarchy_config_check.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

SELECT ms_appl_priv.hierarchy_config_check( ch )
FROM ms_appl_data.conf_hierarchies ch
WHERE ch.id = p_hierarchy_id;

$BODY$
LANGUAGE sql STABLE;

ALTER FUNCTION ms_appl_priv.hierarchy_config_check(p_hierarchy_id uuid)
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION
    ms_appl_priv.hierarchy_config_check(p_hierarchy_id uuid) FROM public;

GRANT EXECUTE ON FUNCTION
    ms_appl_priv.hierarchy_config_check(p_hierarchy_id uuid) TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_appl_priv.hierarchy_config_check(p_hierarchy_id uuid) IS
$DOC$A convenience function allowing the `ms_appl_priv.hierarchy_config_check`
function to be called using a `ms_appl_data.conf_hierarchies.id` value.

Please see the `ms_appl_priv.hierarchy_config_check(ms_appl_data.conf_hierarchies)`
documentation for more information about this function.$DOC$;
