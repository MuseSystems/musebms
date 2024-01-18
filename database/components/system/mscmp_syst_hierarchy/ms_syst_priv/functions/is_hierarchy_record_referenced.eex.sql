CREATE OR REPLACE FUNCTION
    ms_syst_priv.is_hierarchy_record_referenced(
        p_parent_record_id   uuid,
        p_excluded_relations regclass[] DEFAULT null::regclass[] )
RETURNS boolean AS
$BODY$

-- File:        is_hierarchy_record_referenced.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_hierarchy/ms_syst_priv/functions/is_hierarchy_record_referenced.eex.sql
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
            p_table_name         => 'syst_hierarchies',
            p_parent_record_id   => p_parent_record_id,
            p_excluded_relations =>
                coalesce(
                    p_excluded_relations,
                    ARRAY [to_regclass('ms_syst_data.syst_hierarchy_items')]::regclass[]
                )
    );

$BODY$
LANGUAGE sql
    STABLE
    SECURITY DEFINER
    SET search_path TO ms_appl, pg_temp;

ALTER FUNCTION
    ms_syst_priv.is_hierarchy_record_referenced(
        p_parent_record_id   uuid,
        p_excluded_relations regclass[] )
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION
    ms_syst_priv.is_hierarchy_record_referenced(
        p_parent_record_id   uuid,
        p_excluded_relations regclass[] )
    FROM public;

GRANT EXECUTE ON FUNCTION
    ms_syst_priv.is_hierarchy_record_referenced(
        p_parent_record_id   uuid,
        p_excluded_relations regclass[] )
    TO <%= ms_owner %>;

DO
$DOCUMENTATION$
DECLARE
    -- Function
    var_comments_config ms_syst_priv.comments_config_function;

    -- Parameters
    var_p_parent_record_id   ms_syst_priv.comments_config_function_param;
    var_p_excluded_relations ms_syst_priv.comments_config_function_param;
BEGIN

    --
    -- Function Config
    --

    var_comments_config.function_schema := 'ms_syst_priv';
    var_comments_config.function_name   := 'is_hierarchy_record_referenced';

    var_comments_config.description :=
$DOC$Tests if the identified Hierarchy record is referenced by a Hierarchy
implementing Component's data.$DOC$;

    var_comments_config.general_usage :=
$DOC$Returns `TRUE` if the record is referenced, `FALSE` otherwise.  A referenced
record is an indication that a Hierarchy is in active use and should be
prohibited from reconfiguring changes.

If allowed to default, the `p_excluded_relations` parameter excludes the
`ms_syst_data.syst_hierarchy_items` relation.  If you specify a
`p_excluded_relations` value for this parameter, no such default assumptions are
made and only the relations you specify are excluded.$DOC$;

    --
    -- Parameter Configs
    --

    var_p_parent_record_id.param_name := 'p_parent_record_id';
    var_p_parent_record_id.description :=
$DOC$The record ID to search for in the child tables which may reference the value.$DOC$;

    var_p_excluded_relations.param_name := 'p_excluded_relations';
    var_p_excluded_relations.required := FALSE;
    var_p_excluded_relations.default_value :=
$DOC$`'{}'::regclass[]`$DOC$;
    var_p_excluded_relations.description :=
$DOC$An array of regclasses to exclude from the search for the `p_parent_record_id`
value.$DOC$;

    var_comments_config.params :=
        ARRAY [
              var_p_parent_record_id
            , var_p_excluded_relations
            ]::ms_syst_priv.comments_config_function_param[];

    PERFORM ms_syst_priv.generate_comments_function( var_comments_config );

END;
$DOCUMENTATION$;
