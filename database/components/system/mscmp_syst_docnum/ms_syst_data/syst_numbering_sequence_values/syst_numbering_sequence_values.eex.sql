-- File:        syst_numbering_sequence_values.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_docnum/ms_syst_data/syst_numbering_sequence_values/syst_numbering_sequence_values.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_numbering_sequence_values
(
     id
        uuid
        CONSTRAINT syst_numbering_sequence_values_pk PRIMARY KEY
        CONSTRAINT syst_numbering_sequence_values_numbering_sequences_fk
            REFERENCES ms_syst_data.syst_numbering_sequences (id)
    ,next_value
        bigint
);

ALTER TABLE ms_syst_data.syst_numbering_sequence_values OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_numbering_sequence_values FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_numbering_sequence_values TO <%= ms_owner %>;

DO
$DOCUMENTATION$
DECLARE
    -- Table
    var_comments_config ms_syst_priv.comments_config_table;

    -- Columns
    var_next_value ms_syst_priv.comments_config_table_column;

BEGIN

    --
    -- Table Config
    --

    var_comments_config.table_schema := 'ms_syst_data';
    var_comments_config.table_name   := 'syst_numbering_sequence_values';

    var_comments_config.description :=
$DOC$Contains the next value for a parent numbering sequence.$DOC$;

    var_comments_config.general_usage :=
$DOC$This is a quantitative table which is, one record for one record, related to the
qualitative data table ms_syst_data.syst_numbering_sequences. As such,
records in this table are created automatically when a new
`syst_numbering_sequences` record is inserted and the primary key in this table
is set to be the same as its parent `syst_numbering_sequences` record's primary
key value.

Values are consumed from a numbering sequence by calling the function
`ms_syst_priv.get_next_sequence_value` and can be set to a specific desired
value using function `ms_syst_priv.set_next_sequence_value`.  These functions
ensure that the correct updating, locking, and validation are applied to the
sequence value.  Direct updating of these records is discouraged.$DOC$;

    --
    -- Column Configs
    --

    var_next_value.column_name := 'next_value';
    var_next_value.description :=
$DOC$The next value to be returned to callers requesting a number from the
sequence.  $DOC$;
    var_next_value.general_usage :=
$DOC$Note that consuming a sequence should typically be handled using a
`SELECT FOR UPDATE` or similar row locking strategy; the assumption being that
any sequence may be supporting a gap-less numbering need in the application.$DOC$;


    var_comments_config.columns :=
        ARRAY [ var_next_value ]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( var_comments_config );

END;
$DOCUMENTATION$;
