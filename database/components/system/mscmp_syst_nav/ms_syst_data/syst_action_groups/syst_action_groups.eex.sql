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
    ,command
        text
        CONSTRAINT syst_action_groups_command_udx UNIQUE NULLS DISTINCT
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
    ,CONSTRAINT syst_action_groups_command_validity_chk
        CHECK
            ( ( command IS NULL
                    AND command_config IS NULL
                    AND commands_aliases IS NULL
                    AND command_search IS NULL) OR
              ( command IS NOT NULL
                    AND command_config IS NOT NULL
                    AND commands_aliases IS NOT NULL
                    AND command_search IS NOT NULL) )
    ,syst_description
        text
        NOT NULL
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

COMMENT ON
    TABLE ms_syst_data.syst_action_groups IS
$DOC$Defines groups of actions which can be associated with a primary command structure.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_action_groups.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_action_groups.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_action_groups.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_action_groups.command IS
$DOC$Provides the primary text "Command" used for identifying the Action Group.

Commands associated with Action Groups are used for commandline-like input by
application users to specify a class of action.  For example, the Command "new"
may designate a class of Actions which all deal with record or transaction
creation; secondary Commands at the Action level would delineate which specific
creation action to take.

When the value of this column is `NULL`, the Action Group is not searchable or
available to the user using command line interfaces.  Such Action Groups exist
to organize Actions which are only accessible via menu interfaces (or similar).
Note that if this value is `NULL` other `command_*` columns must also be `NULL`.

`command` designated Commands have priority over similar "Command Aliases"
defined in the `command_aliases` column.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_action_groups.command_config IS
$DOC$Establishes the PostgresSQL text search configuration to use when parsing the
Command strings.  The primary use of this column is to set the value of the
generated column `command_search`, though establishing the appropriate
configuration for use with the record may be useful elsewhere.

The null/not null state of this column must match the null/not null state of the
`command` column.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_action_groups.commands_aliases IS
$DOC$An array of strings which designate alternate, possibly non-unique values which
may be used in addition to the `command` value in identifying the record.  In
searched results, `command_aliases` received a reduced priority vs. `command`
values.

The null/not null state of this column must match the null/not null state of the
`command` column.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_action_groups.command_search IS
$DOC$A generated column containing the PostgreSQL tsvector value used when
resolving an Action Group Command.

The null/not null state of this column must match the null/not null state of the
`command` column.$DOC$;

COMMENT ON
    CONSTRAINT syst_action_groups_command_validity_chk
    ON ms_syst_data.syst_action_groups IS
$DOC$Enforces the rule that all `command*` columns share a null/not null state.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_action_groups.syst_description IS
$DOC$The description of the Action Group, its intended purpose, and possible use
cases.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_action_groups.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record 
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_action_groups.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_action_groups.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record 
started.  This field will be the same as diag_timestamp_created for inserted 
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_action_groups.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the 
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_action_groups.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_action_groups.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual 
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version 
is not updated, nor are any updates made to the other diag_* columns other than 
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_action_groups.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if 
the update actually changed any data.  In this way needless or redundant record 
updates can be found.  This row starts at 0 and therefore may be the same as the 
diag_row_version - 1.$DOC$;
