CREATE OR REPLACE FUNCTION
    ms_syst_priv.generate_comments_table(
        p_comments_config ms_syst_priv.comments_config_table)
RETURNS void AS
$BODY$

-- File:        generate_comments_table.eex.sql
-- Location:    musebms/database/all/ms_syst_priv/functions/generate_comments_table.eex.sql
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

    var_resolved_description text;
    var_resolved_general_use text;
    var_resolved_constraints text;
    var_resolved_direct_use  text;

    var_comment text;

BEGIN

    var_resolved_description := p_comments_config.description;

    var_resolved_general_use :=
        E'**General Usage**\n\n' || p_comments_config.general_usage;

    var_resolved_constraints :=
        E'**Constraint Notes**\n\n' || p_comments_config.constraints;

    var_resolved_direct_use :=
        E'**Direct Usage**\n\n' || p_comments_config.direct_usage;

    var_comment :=
            CASE
                WHEN
                    var_resolved_description IS NOT NULL
                        OR var_resolved_general_use IS NOT NULL
                        OR var_resolved_constraints IS NOT NULL
                        OR var_resolved_direct_use IS NOT NULL
                THEN
                    coalesce( var_resolved_description || E'\n\n', '' ) ||
                        coalesce( var_resolved_general_use || E'\n\n', '' ) ||
                        coalesce( var_resolved_constraints || E'\n\n', '' ) ||
                        coalesce( var_resolved_direct_use || E'\n\n', '' )
                ELSE
                    E'This table is not yet documented.\n\n'
            END;

    EXECUTE format( 'COMMENT ON TABLE %1$I.%2$I IS %3$L;',
                    p_comments_config.table_schema,
                    p_comments_config.table_name,
                    var_comment);

    IF coalesce( p_comments_config.generate_common, TRUE ) THEN
        PERFORM
            ms_syst_priv.generate_comments_table_common_columns(
                p_table_schema => p_comments_config.table_schema,
                p_table_name   => p_comments_config.table_name);
    END IF;

    PERFORM
        ms_syst_priv.generate_comments_table_column(
            p_table_schema    => p_comments_config.table_schema,
            p_table_name      => p_comments_config.table_name,
            p_comments_config => c )
    FROM
        unnest( p_comments_config.columns ) c;

END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION
    ms_syst_priv.generate_comments_table(
        p_comments_config ms_syst_priv.comments_config_table)
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION
    ms_syst_priv.generate_comments_table(
        p_comments_config ms_syst_priv.comments_config_table)
    FROM public;

GRANT EXECUTE ON FUNCTION
    ms_syst_priv.generate_comments_table(
        p_comments_config ms_syst_priv.comments_config_table)
    TO <%= ms_owner %>;

COMMENT ON FUNCTION
    ms_syst_priv.generate_comments_table(
        p_comments_config ms_syst_priv.comments_config_table) IS
$DOC$#### Private Function `ms_syst_priv.generate_comments_table`

Generates table comments, and optionally associated column comments, in a
standardized format.

The comments themselves are defined using an object of type
`ms_syst_priv.comment_configs_table` which in turn is used as the parameter of
this function.

#### Parameters

  * `p_comments_config`

    A value of type `ms_syst_priv.comments_config_table` which describes the
    required and optional attributes for generating the column's comments.  See
    the comments for that database type for detailed information.
$DOC$;
