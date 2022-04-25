-- File:        syst_numbering_sequence_values.eex.sql
-- Location:    database\cmp_msbms_syst_numberings\msbms_syst_data\syst_numbering_sequence_values\syst_numbering_sequence_values.eex.sql
-- Project:     Muse Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE msbms_syst_data.syst_numbering_sequence_values
(
     id
        uuid
        CONSTRAINT syst_numbering_sequence_values_pk PRIMARY KEY
        CONSTRAINT syst_numbering_sequence_values_numbering_sequences_fk
            REFERENCES msbms_syst_data.syst_numbering_sequences (id)
    ,next_value
        bigint
);

ALTER TABLE msbms_syst_data.syst_numbering_sequence_values OWNER TO <%= msbms_owner %>;

REVOKE ALL ON TABLE msbms_syst_data.syst_numbering_sequence_values FROM public;
GRANT ALL ON TABLE msbms_syst_data.syst_numbering_sequence_values TO <%= msbms_owner %>;

COMMENT ON
    TABLE msbms_syst_data.syst_numbering_sequence_values IS
$DOC$Contains the next value for a parent numbering sequence.

This is a quantitative table which is, one record for one record, related to the
qualitative data table msbms_syst_data.syst_numbering_sequences. As such,
records in this table are created automatically when a new
syst_numbering_sequences record is inserted and the primary key in this table is
set to be the same as its parent syst_numbering_sequences record's primary key
value.

Values are consumed from a numbering sequence by calling the function
msbms_syst_priv.get_next_sequence_value and can be set to a specific desired
value using function msbms_syst_priv.set_next_sequence_value.  These functions
ensure that the correct updating, locking, and validation are applied to the
sequence value.  Direct updating of these records is discouraged.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_numbering_sequence_values.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_numbering_sequence_values.next_value IS
$DOC$The next value to be returned to callers requesting a number from the
sequence.  Note that consuming a sequence should typically be handled using a
SELECT FOR UPDATE or similar row locking strategy; the assumption being that any
sequence may be supporting a gap-less numbering need in the application.$DOC$;
