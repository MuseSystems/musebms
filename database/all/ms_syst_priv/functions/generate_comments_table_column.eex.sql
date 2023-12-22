CREATE OR REPLACE FUNCTION
    ms_syst_priv.generate_comments_table_column(
        p_table_schema    text,
        p_table_name      text,
        p_comments_config ms_syst_priv.comments_config_table_column)
RETURNS void AS
$BODY$

-- File:        generate_comments_table_column.eex.sql
-- Location:    musebms/database/all/ms_syst_priv/functions/generate_comments_table_column.eex.sql
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
    var_resolved_description   text;
    var_resolved_general_usage text;
    var_resolved_func_type     text;
    var_resolved_life_cycle    text;
    var_resolved_constraint    text;
    var_resolved_direct_usage  text;

    var_comment text;

BEGIN

    var_resolved_description :=
        E'#### Data Table Column `' || p_comments_config.column_name || E'`\n\n' ||
        p_comments_config.description;

    var_resolved_general_usage :=
        E'#### General Usage\n\n' ||
            p_comments_config.general_usage;

    var_resolved_func_type :=
        E'#### Functional Type Reference\n\n' ||
            CASE
                WHEN p_comments_config.func_type_text IS NOT NULL THEN
                    p_comments_config.func_type_text
                WHEN p_comments_config.func_type_name IS NOT NULL THEN
                    'This column references the Functional Types Enumeration \n`' ||
                        p_comments_config.func_type_name ||
                        E'` defined in table `ms_syst_data.syst_enums`\nand its ' ||
                        E'associated tables.\n\n' ||
                        E'Specific available Functional Type values are documented ' ||
                        E'in the records of\nthose tables.'
            END;

    var_resolved_life_cycle :=
        E'#### Life-Cycle State Reference\n\n' ||
            CASE
                WHEN p_comments_config.state_text IS NOT NULL THEN
                    p_comments_config.state_text
                WHEN p_comments_config.state_name IS NOT NULL THEN
                    'This column references the State Enumeration \n`' ||
                        p_comments_config.state_name ||
                        E'` defined in table `ms_syst_data.syst_enums`\nand' ||
                        E' its associated tables.\n\nSpecific available ' ||
                        E'State values are documented in the records of ' ||
                        E'those tables.'
            END;

    var_resolved_constraint :=
        E'#### Constraint Reference\n\n' ||
            p_comments_config.constraints;

    var_resolved_direct_usage :=
        E'#### Direct Usage\n\n' ||
            p_comments_config.direct_usage;

    var_comment :=
        CASE
            WHEN
                var_resolved_description IS NOT NULL
                    OR var_resolved_general_usage IS NOT NULL
                    OR var_resolved_func_type IS NOT NULL
                    OR var_resolved_life_cycle IS NOT NULL
                    OR var_resolved_constraint IS NOT NULL
                    OR var_resolved_direct_usage IS NOT NULL
            THEN
                coalesce( var_resolved_description || E'\n\n', '' ) ||
                    coalesce( var_resolved_general_usage || E'\n\n', '' ) ||
                    coalesce( var_resolved_func_type || E'\n\n', '' ) ||
                    coalesce( var_resolved_life_cycle || E'\n\n', '' ) ||
                    coalesce( var_resolved_constraint || E'\n\n', '' ) ||
                    coalesce( var_resolved_direct_usage || E'\n\n', '' )
            ELSE
                E'This table column is not yet documented.\n\n'
        END;

    EXECUTE format( 'COMMENT ON COLUMN %1$I.%2$I.%3$I IS %4$L;',
                    p_table_schema,
                    p_table_name,
                    p_comments_config.column_name,
                    var_comment );

END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION
    ms_syst_priv.generate_comments_table_column(
        p_table_schema    text,
        p_table_name      text,
        p_comments_config ms_syst_priv.comments_config_table_column)
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION
    ms_syst_priv.generate_comments_table_column(
        p_table_schema    text,
        p_table_name      text,
        p_comments_config ms_syst_priv.comments_config_table_column)
    FROM public;

GRANT EXECUTE ON FUNCTION
    ms_syst_priv.generate_comments_table_column(
        p_table_schema    text,
        p_table_name      text,
        p_comments_config ms_syst_priv.comments_config_table_column)
    TO <%= ms_owner %>;

COMMENT ON FUNCTION
    ms_syst_priv.generate_comments_table_column(
        p_table_schema    text,
        p_table_name      text,
        p_comments_config ms_syst_priv.comments_config_table_column)
    IS
$DOC$#### Private Function `ms_syst_priv.generate_comments_table_column`

Generates table column comments in a standardized format.

The comments themselves are defined using a configuration type containing the
column documentation and comment related configurations.

#### Parameters

  * `p_table_schema`

    The database schema where the column is defined.

  * `p_table_name`

    The database table where the column is defined.

  * `p_comments_config`

    A value of type `ms_syst_priv.comments_config_table_column` which describes
    the required and optional attributes for generating the column's comments.
    See the comments for that database type for detailed information.
$DOC$;
