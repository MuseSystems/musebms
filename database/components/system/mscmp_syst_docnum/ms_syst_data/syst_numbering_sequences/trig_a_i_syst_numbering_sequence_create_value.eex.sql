CREATE OR REPLACE FUNCTION ms_syst_data.trig_a_i_syst_numbering_sequence_create_value()
RETURNS trigger AS
$BODY$

-- File:        trig_a_i_syst_numbering_sequence_create_value.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_docnum/ms_syst_data/syst_numbering_sequences/trig_a_i_syst_numbering_sequence_create_value.eex.sql
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

    INSERT INTO ms_syst_data.syst_numbering_sequence_values
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

ALTER FUNCTION ms_syst_data.trig_a_i_syst_numbering_sequence_create_value()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_data.trig_a_i_syst_numbering_sequence_create_value() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_data.trig_a_i_syst_numbering_sequence_create_value() TO <%= ms_owner %>;

DO
$DOCUMENTATION$
DECLARE
    -- Function
    var_comments_config ms_syst_priv.comments_config_function;

BEGIN

    --
    -- Function Config
    --

    var_comments_config.function_schema := 'ms_syst_data';
    var_comments_config.function_name   := 'trig_a_i_syst_numbering_sequence_create_value';

    var_comments_config.trigger_function := TRUE;
    var_comments_config.trigger_timing   := ARRAY [ 'a' ]::text[ ];
    var_comments_config.trigger_ops      := ARRAY [ 'i' ]::text[ ];

    var_comments_config.description :=
$DOC$Automatically creates a ms_syst_data.syst_numbering_sequence_values record
based on the configuration of the sequence in the syst_numbering_sequences
record.$DOC$;

    var_comments_config.general_usage :=
$DOC$If a sequence is incrementing, the minimum value is used set as the
next value; if the sequence is decrementing, the maximum value is used to set
the starting value.$DOC$;

    PERFORM ms_syst_priv.generate_comments_function( var_comments_config );

END;
$DOCUMENTATION$;
