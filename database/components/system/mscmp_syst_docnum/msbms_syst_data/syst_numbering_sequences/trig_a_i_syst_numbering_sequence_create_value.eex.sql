CREATE OR REPLACE FUNCTION msbms_syst_data.trig_a_i_syst_numbering_sequence_create_value()
RETURNS trigger AS
$BODY$

-- File:        trig_a_i_syst_numbering_sequence_create_value.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_docnum/msbms_syst_data/syst_numbering_sequences/trig_a_i_syst_numbering_sequence_create_value.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

BEGIN

    INSERT INTO msbms_syst_data.syst_numbering_sequence_values
        ( id, next_value )
    VALUES
        ( new.id, CASE sign( new.value_increment )
                      WHEN 1  THEN lower(new.allowed_value_range)
                      WHEN -1 THEN upper(new.allowed_value_range)
                  END );

    RETURN NULL;

END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION msbms_syst_data.trig_a_i_syst_numbering_sequence_create_value()
    OWNER TO <%= msbms_owner %>;

REVOKE EXECUTE ON FUNCTION msbms_syst_data.trig_a_i_syst_numbering_sequence_create_value() FROM public;
GRANT EXECUTE ON FUNCTION msbms_syst_data.trig_a_i_syst_numbering_sequence_create_value() TO <%= msbms_owner %>;

COMMENT ON FUNCTION msbms_syst_data.trig_a_i_syst_numbering_sequence_create_value() IS
$DOC$Automatically creates a msbms_syst_data.syst_numbering_sequence_values record
based on the configuration of the sequence in the syst_numbering_sequences
record.  If a sequence is incrementing, the minimum value is used set as the
next value; if the sequence is decrementing, the maximum value is used to set
the starting value.$DOC$;
