-- File:        syst_actions.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_nav/ms_syst_data/syst_actions/syst_actions.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TABLE ms_syst_data.syst_actions
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_actions_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_actions_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT syst_actions_display_name_udx UNIQUE
    ,external_name
        text
        NOT NULL
    ,action_group_id
        uuid
        NOT NULL
        CONSTRAINT syst_actions_action_group_fk
            REFERENCES ms_syst_data.syst_action_groups ( id )
    ,command
        text
    ,CONSTRAINT syst_action_group_actions_command_udx
        UNIQUE NULLS DISTINCT (action_group_id, command)
    ,command_config
        regconfig
    ,commands_aliases
        text[]
    ,command_search
         tsvector
         GENERATED ALWAYS AS
             ( ms_syst_priv.generate_command_tsvector(
                 p_config => command_config,
                 p_command => command,
                 p_command_aliases => commands_aliases ) )
             STORED
    ,CONSTRAINT syst_actions_command_validity_chk
        CHECK
            ( ( command IS NULL
                    AND command_config IS NULL
                    AND commands_aliases IS NULL
                    AND command_search IS NULL) OR
              ( command IS NOT NULL
                    AND command_config IS NOT NULL
                    AND commands_aliases IS NOT NULL
                    AND command_search IS NOT NULL) )
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

ALTER TABLE ms_syst_data.syst_actions OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_actions FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_actions TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_actions
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE INDEX syst_actions_action_group_idx
    ON ms_syst_data.syst_actions ( action_group_id );

CREATE INDEX syst_actions_command_search_idx
    ON ms_syst_data.syst_actions USING GIN ( command_search );

COMMENT ON
    TABLE ms_syst_data.syst_actions IS
$DOC$Defines actions which may be taken when a Menu Item is "selected" or the defined
Command is entered by a user.  Actions may be associated with a Menu Item, may
define a Command, or both.  Actions which are not referenced by a Menu Item and
do not define a Command for access will effectively not be active in the
application as there will be no way to resolve/invoke the action.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_actions.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_actions.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_actions.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_actions.external_name IS
$DOC$A non-unique/non-key value used to display to users and external parties where
uniqueness is less of a concern than specific end user presentation.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_actions.action_group_id IS
$DOC$If the Action is to be accessible via Command entry, it must define a parent
Action Group which is done via the value in this column.  If the Action is not
accessible via Commands, this value should be left `NULL`.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_actions.command IS
$DOC$Provides the primary text "Command" used for identifying the Action.

Commands associated with Actions are used for commandline-like input by
application users to select the specific action to take assuming the Action
Group has been resolved..  For example, the Command "po", when taken from the
Action Group identified with Command "new", could indicate that the user wishes
to create a new purchase order.

When the value of this column is `NULL`, the Action is not searchable or
available to the user using command line interfaces.  Such Actions exist if they
are only invokable from menus or similar, non-commandline user interfaces.
Note that if this value is `NULL` other `command_*` columns must also be `NULL`.

`command` designated Commands have priority over similar "Command Aliases"
defined in the `command_aliases` column.$DOC$;

COMMENT ON
    CONSTRAINT syst_action_group_actions_command_udx
    ON ms_syst_data.syst_actions IS
$DOC$Action Commands may be duplicated across Action Groups.  For example this
allows the Action Groups "new" and "open" to both share Actions identified by
the same Action Command "po" or "purchase order".  Action Commands must be
unique within an Action Group to remain unambiguous.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_actions.command_config IS
$DOC$Establishes the PostgresSQL text search configuration to use when parsing the
Command strings.  The primary use of this column is to set the value of the
generated column `command_search`, though establishing the appropriate
configuration for use with the record may be useful elsewhere.

The null/not null state of this column must match the null/not null state of the
`command` column.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_actions.commands_aliases IS
$DOC$An array of strings which designate alternate, possibly non-unique values which
may be used in addition to the `command` value in identifying the record.  In
searched results, `command_aliases` received a reduced priority vs. `command`
values.

The null/not null state of this column must match the null/not null state of the
`command` column.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_actions.command_search IS
$DOC$A generated column containing the PostgreSQL tsvector value used when
resolving an Action Command.

The null/not null state of this column must match the null/not null state of the
`command` column.$DOC$;

COMMENT ON
    CONSTRAINT syst_actions_command_validity_chk
    ON ms_syst_data.syst_actions IS
$DOC$Enforces the rule that all `command*` columns share a null/not null state.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_actions.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_actions.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_actions.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_actions.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_actions.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_actions.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_actions.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
