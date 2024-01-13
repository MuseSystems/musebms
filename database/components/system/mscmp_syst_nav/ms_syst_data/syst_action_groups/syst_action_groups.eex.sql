-- File:        syst_action_groups.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_nav/ms_syst_data/syst_action_groups/syst_action_groups.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TABLE ms_syst_data.syst_action_groups
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v7( )
        CONSTRAINT syst_action_groups_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_action_groups_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT syst_action_groups_display_name_udx UNIQUE
    ,external_name
        text
        NOT NULL
    ,command
        text
        CONSTRAINT syst_action_groups_command_udx UNIQUE NULLS DISTINCT
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
    ,CONSTRAINT syst_action_groups_command_validity_chk
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
    ,user_maintainable
        boolean
        NOT NULL DEFAULT TRUE
    ,syst_description
        text
        NOT NULL
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

ALTER TABLE ms_syst_data.syst_action_groups OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_action_groups FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_action_groups TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_action_groups
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE INDEX syst_action_groups_command_search_idx
    ON ms_syst_data.syst_action_groups USING GIN ( command_search );

DO
$DOCUMENTATION$
DECLARE
    var_comments_config ms_syst_priv.comments_config_table;

    var_command          ms_syst_priv.comments_config_table_column;
    var_command_config   ms_syst_priv.comments_config_table_column;
    var_command_aliases  ms_syst_priv.comments_config_table_column;
    var_command_search   ms_syst_priv.comments_config_table_column;

BEGIN
    var_comments_config.table_schema := 'ms_syst_data';
    var_comments_config.table_name   := 'syst_action_groups';


    var_comments_config.description :=
$DOC$Defines groups of actions which can be associated with an invoking primary
command.

There are two fundamental roles fulfilled by the Action Group.  The first of
these is a simple organizing role related to child Action records
(`ms_syst_data.syst_actions`); there is little functional purpose to this first
role aside from user interface categorization.

The second fundamental role establishes the Primary Command component of a user
commandline interaction model.  The Primary Commands defined by Action Groups
express the general action a user wishes to take: "new", "open", "display" are
examples of such generalized actions.  These generalized actions in turn can
then be specialized using a secondary Command (defined by Actions) to a specific
system function: "new purchase order", "new sales order", "open sales order",
"display report" are examples showing how the generalized commands (Action
Group) are tied to specific Action commands (Actions).$DOC$;

    var_command.column_name := 'command';
    var_command.description :=
$DOC$Provides the primary text "Command" used for identifying the Action Group.

Commands associated with Action Groups are used for commandline-like input by
application users to specify a class of action.  For example, the Command "new"
may designate a class of Actions which all deal with record or transaction
creation; secondary Commands at the Action level would delineate which specific
creation action to take.$DOC$;

    var_command.general_usage :=
$DOC$When the value of this column is `NULL`, the Action Group is not searchable or
available to the user using command line interfaces.  Such Action Groups exist
to organize Actions which are only accessible via menu interfaces (or similar).
Note that if this value is `NULL` other `command_*` columns must also be `NULL`.

`command` designated Commands have priority over similar "Command Aliases"
defined in the `command_aliases` column.$DOC$;

    var_command_config.column_name := 'command_config';
    var_command_config.description :=
$DOC$Establishes the PostgresSQL text search configuration to use when parsing the
Command strings.  The primary use of this column is to set the value of the
generated column `command_search`, though establishing the appropriate
configuration for use with the record may be useful elsewhere.$DOC$;

    var_command_config.general_usage :=
$DOC$The null/not null state of this column must match the null/not null state of the
`command` column.$DOC$;

    var_command_aliases.column_name := 'command_aliases';
    var_command_aliases.description :=
$DOC$An array of strings which designate alternate, possibly non-unique values which
may be used in addition to the `command` value in identifying the record.  In
searched results, `command_aliases` received a reduced priority vs. `command`
values.$DOC$;


    var_command_aliases.general_usage :=
$DOC$The null/not null state of this column must match the null/not null state of the
`command` column.$DOC$;

    var_command_search.column_name := 'command_search';
    var_command_search.description :=
$DOC$A generated column containing the PostgreSQL tsvector value used when resolving
an Action Group Command.  Being a generated column, the system will
automatically update this column when its source columns are updated.$DOC$;

    var_command_search.general_usage :=
$DOC$Being a generated column, the system will automatically update this column when
its source columns are updated.  The null/not null state of this column will
match the null/not null state of the `command` column.$DOC$;

    var_comments_config.columns :=
        ARRAY
            [
              var_command
            , var_command_config
            , var_command_aliases
            , var_command_search
            ]::ms_syst_priv.comments_config_table_column[];


    PERFORM ms_syst_priv.generate_comments_table( var_comments_config );

END;
$DOCUMENTATION$;

COMMENT ON
    CONSTRAINT syst_action_groups_command_validity_chk
    ON ms_syst_data.syst_action_groups IS
$DOC$Enforces the rule that all `command*` columns share a null/not null state.$DOC$;
