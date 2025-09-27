-- File:        syst_numbering_segments.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_docnum/ms_syst_data/syst_numbering_segments/syst_numbering_segments.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_numbering_segments
(
     id
        uuid
        NOT NULL DEFAULT uuidv7( )
        CONSTRAINT syst_numbering_segments_pk PRIMARY KEY
    ,numbering_id
        uuid
        NOT NULL
        CONSTRAINT syst_numbering_segments_numberings_fk
            REFERENCES ms_syst_data.syst_numberings (id) ON DELETE CASCADE
    ,sort_order
        smallint
        NOT NULL DEFAULT 1
    ,numbering_segment_type_id
        uuid
        NOT NULL
        CONSTRAINT syst_numbering_segments_numbering_segment_types_fk
            REFERENCES ms_syst_data.syst_numbering_segment_types (id)
    ,display_length
        smallint
        NOT NULL
        CONSTRAINT syst_numbering_segments_display_length_validation_chk
            CHECK ( display_length >= 0 )
    ,use_padding
        boolean
        NOT NULL DEFAULT TRUE
    ,padding_side
        text
        CONSTRAINT syst_numbering_segments_padding_side_validation_chk
            CHECK ( NOT use_padding OR
                    (padding_side IS NOT NULL AND
                     padding_side IN ('start', 'end')) )
    ,padding_text
        text
        CONSTRAINT syst_numbering_segments_padding_text_validation_chk
            CHECK ( NOT use_padding OR padding_text IS NOT NULL )
    ,fixed_text
        text
        CONSTRAINT syst_numbering_segments_fixed_text_validation_chk
            CHECK ( fixed_text IS NULL OR length(fixed_text) <= display_length )
    ,freetext_validator
        text
    ,enum_id
        uuid
        CONSTRAINT syst_numbering_segments_enums_fk
            REFERENCES ms_syst_data.syst_enums (id)
    ,numbering_sequence_id
        uuid
        CONSTRAINT syst_numbering_segments_numbering_sequences_fk
            REFERENCES ms_syst_data.syst_numbering_sequences (id)
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
    ,CONSTRAINT syst_numbering_segments_numbering_sort_order_udx
        UNIQUE ( numbering_id, sort_order )
);

ALTER TABLE ms_syst_data.syst_numbering_segments OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_numbering_segments FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_numbering_segments TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_numbering_segments
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

DO
$DOCUMENTATION$
DECLARE
    -- Table
    v_comments_config ms_syst_priv.comments_config_table;

    -- Columns
    v_sort_order                ms_syst_priv.comments_config_table_column;
    v_numbering_segment_type_id ms_syst_priv.comments_config_table_column;
    v_display_length            ms_syst_priv.comments_config_table_column;
    v_use_padding               ms_syst_priv.comments_config_table_column;
    v_padding_side              ms_syst_priv.comments_config_table_column;
    v_padding_text              ms_syst_priv.comments_config_table_column;
    v_fixed_text                ms_syst_priv.comments_config_table_column;
    v_freetext_validator        ms_syst_priv.comments_config_table_column;
    v_enum_id                   ms_syst_priv.comments_config_table_column;
    v_numbering_sequence_id     ms_syst_priv.comments_config_table_column;

BEGIN

    --
    -- Table Config
    --

    v_comments_config.table_schema := 'ms_syst_data';
    v_comments_config.table_name   := 'syst_numbering_segments';

    v_comments_config.description :=
$DOC$Defines the segments which make up a "numbering" in the application.$DOC$;

    --
    -- Column Configs
    --

    v_sort_order.column_name := 'sort_order';
    v_sort_order.description :=
$DOC$Determines the positioning of the segment in the final number constructed from
all segments.$DOC$;

    v_numbering_segment_type_id.column_name := 'numbering_segment_type_id';
    v_numbering_segment_type_id.description :=
$DOC$References the syst_numbering_segment_types table to define the type of
segment represented by the record.$DOC$;

    v_display_length.column_name := 'display_length';
    v_display_length.description :=
$DOC$Sets the presentation length of sequence.  Numbering values that exceed the
display length will raise exceptions.$DOC$;

    v_use_padding.column_name := 'use_padding';
    v_use_padding.description :=
$DOC$If true, any numbering values which would present fewer characters than the
display length will be padded using the padding_text value up to the display
length.  If false, no padding is used and the presentation of the segment may
vary.$DOC$;

    v_padding_side.column_name := 'padding_side';
    v_padding_side.description :=
$DOC$If padding is used, then this value determines on which side of the numbering
value the padding should be applied.  Possible values are:

    * left:  Padding will be added to the left of the numbering value.

    * right: Padding will be added to the right of the numbering value.$DOC$;

    v_padding_text.column_name := 'padding_text';
    v_padding_text.description :=
$DOC$The text to be used in applying padding to numbering values.  If the
padding_text is smaller than the display_length of the segment, the padding text
may be applied repeatedly to fill the unused characters up to the display
length.  If the padding text is larger than the display_length, then any
characters that are beyond the display_length are simply ignored.$DOC$;

    v_fixed_text.column_name := 'fixed_text';
    v_fixed_text.description :=
$DOC$If the segment is of a fixed text segment type, this column records the
numbering value.  Note that this value must not exceed the display_length value
of the segment.$DOC$;

    v_freetext_validator.column_name := 'freetext_validator';
    v_freetext_validator.description :=
$DOC$A regular expression which will allow the application to test whether or not
a presented free text value meets the expectations of the numbering segment.
Such a validation might restrict a free text numbering value to be only numeric
or all upper case, etc.$DOC$;

    v_enum_id.column_name := 'enum_id';
    v_enum_id.description :=
$DOC$If the segment type indicates that the segment gets its value from an
list of values configured in the system's enumerations, this column identified
which enumeration configuration is used to generate the list of values.$DOC$;

    v_numbering_sequence_id.column_name := 'numbering_sequence_id';
    v_numbering_sequence_id.description :=
$DOC$If the segment is of a numeric sequence type, this column references the
sequence to be used in generating numbers.$DOC$;


    v_comments_config.columns :=
        ARRAY [
              v_sort_order
            , v_numbering_segment_type_id
            , v_display_length
            , v_use_padding
            , v_padding_side
            , v_padding_text
            , v_fixed_text
            , v_freetext_validator
            , v_enum_id
            , v_numbering_sequence_id
            ]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( v_comments_config );

END;
$DOCUMENTATION$;
