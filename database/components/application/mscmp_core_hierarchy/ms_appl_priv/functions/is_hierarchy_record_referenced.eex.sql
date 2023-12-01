CREATE OR REPLACE FUNCTION
    ms_appl_priv.is_hierarchy_record_referenced(
        p_parent_record_id   uuid,
        p_excluded_relations regclass[] DEFAULT null::regclass[] )
RETURNS boolean AS
$BODY$

-- File:        is_hierarchy_record_referenced.eex.sql
-- Location:    musebms/database/components/application/mscmp_core_hierarchy/ms_appl/functions/is_hierarchy_record_referenced.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

SELECT
    ms_syst_priv.is_parent_record_referenced(
            p_table_schema       => 'ms_appl_data',
            p_table_name         => 'conf_hierarchies',
            p_parent_record_id   => p_parent_record_id,
            p_excluded_relations =>
                coalesce(
                    p_excluded_relations,
                    ARRAY [to_regclass('ms_appl_data.conf_hierarchy_items')]::regclass[]
                )
    );

$BODY$
LANGUAGE sql
    STABLE
    SECURITY DEFINER
    SET search_path TO ms_appl, pg_temp;

ALTER FUNCTION
    ms_appl_priv.is_hierarchy_record_referenced(
        p_parent_record_id   uuid,
        p_excluded_relations regclass[] )
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION
    ms_appl_priv.is_hierarchy_record_referenced(
        p_parent_record_id   uuid,
        p_excluded_relations regclass[] )
    FROM public;

GRANT EXECUTE ON FUNCTION
    ms_appl_priv.is_hierarchy_record_referenced(
        p_parent_record_id   uuid,
        p_excluded_relations regclass[] )
    TO <%= ms_owner %>;

COMMENT ON FUNCTION
    ms_appl_priv.is_hierarchy_record_referenced(
        p_parent_record_id   uuid,
        p_excluded_relations regclass[] )
    IS
$DOC$Tests if the identified Hierarchy record is referenced by a Hierarchy
implementing Component's data.

Returns `TRUE` if the record is referenced, `FALSE` otherwise.  A referenced
record is an indication that a Hierarchy is in active use and should be
prohibited from reconfiguring changes.

If allowed to default, the `p_excluded_relations` parameter excludes the
`ms_appl_data.conf_hierarchy_items` relation.  If you specify a
`p_excluded_relations` value for this parameter, no such default assumptions are
made and only the relations you specify are excluded.$DOC$;
