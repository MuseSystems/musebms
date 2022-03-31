-- File:        syst_numbering_sequences.eex.sql
-- Location:    database\common\msbms_syst_data\tables\syst_numbering_sequences.eex.sql
-- Project:     Muse Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE msbms_syst_data.syst_numbering_sequences
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_numbering_sequences_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_numbering_sequences_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT syst_numbering_sequences_display_name_udx UNIQUE
    ,globally_assignable
        boolean
        NOT NULL DEFAULT FALSE
    ,allowed_value_range
        int8range
        NOT NULL DEFAULT int8range(1, 9223372036854775806, '[]')
    ,value_increment
        bigint
        NOT NULL DEFAULT 1
        CONSTRAINT syst_numbering_sequences_value_increment_validation_chk
            CHECK (sign(value_increment) != 0)
    ,style_type
        text
        NOT NULL DEFAULT 'base10'
        CONSTRAINT syst_numbering_segments_numeric_representation_type_chk
            CHECK (style_type IN
                   ('base10', 'base36', 'obfuscated_base36', 'alpha_base26'))
    ,cycle_policy
        text
        NOT NULL DEFAULT 'error'
        CONSTRAINT syst_numbering_segments_sequence_cycle_policy_chk
            CHECK ( cycle_policy IN
                    ( 'cycle', 'error' ) )
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

ALTER TABLE msbms_syst_data.syst_numbering_sequences OWNER TO <%= msbms_owner %>;

REVOKE ALL ON TABLE msbms_syst_data.syst_numbering_sequences FROM public;
GRANT ALL ON TABLE msbms_syst_data.syst_numbering_sequences TO <%= msbms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON msbms_syst_data.syst_numbering_sequences
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE TRIGGER a50_trig_a_i_syst_numbering_sequence_create_value
    AFTER INSERT ON msbms_syst_data.syst_numbering_sequences
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst_priv.trig_a_i_syst_numbering_sequence_create_value();

COMMENT ON
    TABLE msbms_syst_data.syst_numbering_sequences IS
$DOC$For numbering segments which are driven by a numbering sequence, this record
defines the configuration settings which influence behavior the behavior of the
sequence.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_numbering_sequences.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_numbering_sequences.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_numbering_sequences.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_numbering_sequences.globally_assignable IS
$DOC$If true, the numbering sequence may be used by more than one segment or more
than one numbering configuration.  If false, the sequence backs a single,
specific numbering segment.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_numbering_sequences.allowed_value_range IS
$DOC$The range of valid values that the sequence may dispense.  By default the
valid range is 1 to 9223372036854775806, though the range may be defined for any
values between -9223372036854775807 and 9223372036854775806, +/- 1 of the
PostgreSQL bigint data type's maximum values.  Please note that the trigger
condition for either cycling the sequence or raising a sequence range exceed
exception is when the next_value column is found to be minimum allowed value -1
or the maximum allowed value +1; the cycle or exception will happen when a
request would be answered with an out-of-range value, not at the time the last
value allowed by the range was consumed.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_numbering_sequences.value_increment IS
$DOC$The value by which the number is incremented or decremented when a request for
a numbering sequence value is made.  This value must be set to a non-zero value.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_numbering_sequences.style_type IS
$DOC$Indicates the presentation style of the value.  Supported style types are:

    *  base10:            Typical decimal numeric formatting.

    *  base36:            A representation of the value using digits 0-9 & A-Z.

    *  obfuscated_base36: Same as base36 except the number places are mixed in
                          order to obscure the sequence nature of the underlying
                          numbering scheme.  This scheme works best when the
                          allowed_value_range is set to generate numbers with
                          sufficient size to create 6 or more base36 digits.

    *  alpha_base26:      Number values are represented only as alphabetic
                          values (A-Z).  This numbering system is base26 and
                          so does achieve some value compression as compared to
                          base10/decimal.
$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_numbering_sequences.cycle_policy IS
$DOC$Indicates what the correct course of action is once a numbering sequence has
reached the limit of its allowed_value_range.  The acceptable values for ths
column are:

    *  cycle: Restart the numbering at the beginning of the range as determined
              by the value_increment.

    *  error: Raise an exception and cease to produce values from the sequence.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_numbering_sequences.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_numbering_sequences.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_numbering_sequences.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_numbering_sequences.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_numbering_sequences.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_numbering_sequences.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_numbering_sequences.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
