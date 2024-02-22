-- File:        syst_nav_actions.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_nav/ms_syst_data/syst_nav_actions/syst_nav_actions.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TABLE ms_syst_data.syst_nav_actions
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v7( )
        CONSTRAINT syst_nav_actions_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_nav_actions_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT syst_nav_actions_display_name_udx UNIQUE
    ,external_name
        text
        NOT NULL
    ,action_group_id
        uuid
        NOT NULL
        CONSTRAINT syst_nav_actions_action_group_fk
            REFERENCES ms_syst_data.syst_nav_action_groups ( id )
    ,command
        text
    ,CONSTRAINT syst_action_group_actions_command_udx
        UNIQUE NULLS DISTINCT (action_group_id, command)
    ,command_config
        regconfig
    ,command_aliases
        text[]
    ,command_search
         tsvector
         GENERATED ALWAYS AS
             ( ms_syst_priv.generate_command_tsvector(
                 p_config => command_config,
                 p_command => command,
                 p_command_aliases => command_aliases ) )
             STORED
    ,CONSTRAINT syst_nav_actions_command_validity_chk
        CHECK
            ( ( command IS NULL
                    AND command_config IS NULL
                    AND command_aliases IS NULL
                    AND command_search IS NULL) OR
              ( command IS NOT NULL
                    AND command_config IS NOT NULL
                    AND command_aliases IS NOT NULL
                    AND command_search IS NOT NULL) )
    ,syst_defined
        boolean
        NOT NULL DEFAULT FALSE
    ,syst_description
        text
        NOT NULL
    ,user_maintainable
        boolean
        NOT NULL DEFAULT TRUE
    ,user_description
        text
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
);

ALTER TABLE ms_syst_data.syst_nav_actions OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_nav_actions FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_nav_actions TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_nav_actions
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE INDEX syst_nav_actions_action_group_idx
    ON ms_syst_data.syst_nav_actions ( action_group_id );

CREATE INDEX syst_nav_actions_command_search_idx
    ON ms_syst_data.syst_nav_actions USING GIN ( command_search );

DO
$DOCUMENTATION$
DECLARE
    -- Table
    var_comments_config ms_syst_priv.comments_config_table;

    -- Columns
    var_action_group_id ms_syst_priv.comments_config_table_column;
    var_command         ms_syst_priv.comments_config_table_column;
    var_command_config  ms_syst_priv.comments_config_table_column;
    var_command_aliases ms_syst_priv.comments_config_table_column;
    var_command_search  ms_syst_priv.comments_config_table_column;

BEGIN

    --
    -- Table Config
    --

    var_comments_config.table_schema := 'ms_syst_data';
    var_comments_config.table_name   := 'syst_nav_actions';

    var_comments_config.description :=
$DOC$Defines actions which may be taken when a Menu Item is "selected" or the defined
Command is entered by a user.$DOC$;
    var_comments_config.general_usage :=
$DOC$Actions may be associated with a Menu Item, may define a Command, or both.
Actions which are not referenced by a Menu Item and do not define a Command for
access will effectively not be active in the application as there will be no way
to resolve/invoke the action.$DOC$;

    --
    -- Column Configs
    --

    var_action_group_id.column_name := 'action_group_id';
    var_action_group_id.description :=
$DOC$Defines the Action Group to which the Action record belongs.$DOC$;

    var_command.column_name := 'command';
    var_command.description :=
$DOC$Provides the primary text "Command" used for identifying the Action.

Commands associated with Actions are used for commandline-like input by
application users to select the specific action to take assuming the Action
Group has been resolved..  For example, the Command "po", when taken from the
Action Group identified with Command "new", could indicate that the user wishes
to create a new purchase order.$DOC$;
    var_command.general_usage :=
$DOC$When the value of this column is `NULL` or the parent Action Group defines no
Command, the Action is not searchable or available to the user using command
line interfaces.  Such Actions exist if they are only invokable from menus or
similar, non-commandline user interfaces.

`command` designated Commands have priority over similar "Command Aliases"
defined in the `command_aliases` column.$DOC$;
    var_command.constraints :=
$DOC$If this value is `NULL` other `command_*` columns in the record must also be
`NULL`.$DOC$;


    var_command_config.column_name := 'command_config';
    var_command_config.description :=
$DOC$Establishes the PostgresSQL text search configuration to use when parsing the
Command strings.  The primary use of this column is to set the value of the
generated column `command_search`, though establishing the appropriate
configuration for use with the record may be useful elsewhere.$DOC$;
    var_comments_config.constraints :=
$DOC$The null/not null state of this column must match the null/not null state of the
`command` column.$DOC$;

    var_command_aliases.column_name := 'command_aliases';
    var_command_aliases.description :=
$DOC$An array of strings which designate alternate, possibly non-unique values which
may be used in addition to the `command` value in identifying the record.  In
searched results, `command_aliases` received a reduced priority vs. `command`
values.$DOC$;
    var_command_aliases.constraints :=
$DOC$The null/not null state of this column must match the null/not null state of the
`command` column.$DOC$;

    var_command_search.column_name := 'command_search';
    var_command_search.description :=
$DOC$A generated column containing the PostgreSQL tsvector value used when
resolving an Action Command.$DOC$;
    var_command_search.constraints :=
$DOC$The null/not null state of this column must match the null/not null state of the
`command` column.$DOC$;

    var_comments_config.columns :=
        ARRAY [
              var_action_group_id
            , var_command
            , var_command_config
            , var_command_aliases
            , var_command_search
            ]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( var_comments_config );

END;
$DOCUMENTATION$;

COMMENT ON
    CONSTRAINT syst_nav_actions_command_validity_chk
    ON ms_syst_data.syst_nav_actions IS
$DOC$Enforces the rule that all `command*` columns share a null/not null state.$DOC$;

COMMENT ON
    CONSTRAINT syst_action_group_actions_command_udx
    ON ms_syst_data.syst_nav_actions IS
$DOC$Action Commands may be duplicated across Action Groups.  For example this
allows the Action Groups "new" and "open" to both share Actions identified by
the same Action Command "po" or "purchase order".  Action Commands must be
unique within an Action Group to remain unambiguous.$DOC$;
