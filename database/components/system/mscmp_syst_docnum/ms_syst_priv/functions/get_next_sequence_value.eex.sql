CREATE OR REPLACE FUNCTION
    ms_syst_priv.get_next_sequence_value( p_numbering_sequence_id uuid )
RETURNS bigint AS
$BODY$

-- File:        get_next_sequence_value.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_docnum/ms_syst_priv/functions/get_next_sequence_value.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

DECLARE
    var_context_data   record;
    var_new_next_value bigint;
    var_return_value   bigint;

BEGIN

    SELECT INTO var_context_data
         sns.id
        ,sns.allowed_value_range
        ,sns.cycle_policy
        ,sns.value_increment
        ,snsv.next_value
    FROM ms_syst_data.syst_numbering_sequences  sns
        JOIN ms_syst_data.syst_numbering_sequence_values snsv
            ON snsv.id = sns.id
    WHERE sns.id = p_numbering_sequence_id
    FOR NO KEY UPDATE OF ms_syst_data.syst_numbering_sequence_values;

    var_return_value   := var_context_data.next_value;

    -- It's possible that next_value + value_increment can exceed both the bounds of the
    -- allowed_value_range and even the data type of next_value.  So we need to test for that and
    -- be sure that we don't create some sort of error condition because we broke the type bounds on
    -- update.
    IF NOT var_context_data.allowed_value_range @> var_context_data.next_value THEN

        CASE var_context_data.cycle_policy
            WHEN 'cycle' THEN

                var_return_value :=
                    CASE sign(var_context_data.value_increment)
                        WHEN 1 THEN lower(var_context_data.allowed_value_range)
                        WHEN -1 THEN upper(var_context_data.allowed_value_range)
                    END;

                var_new_next_value := var_return_value + var_context_data.value_increment;

            WHEN 'error' THEN

                RAISE EXCEPTION
                    USING
                        MESSAGE = 'The requested numbering sequence has exhausted its available ' ||
                                  'values and is not allowed to automatically cycle back to its ' ||
                                  'starting value.',
                        DETAIL  = ms_syst_priv.get_exception_details(
                                     p_proc_schema    => 'ms_syst_priv'
                                    ,p_proc_name      => 'get_next_sequence_value'
                                    ,p_exception_name => 'numbering_sequence_out_of_range'
                                    ,p_errcode        => 'PM006'
                                    ,p_param_data     =>
                                        jsonb_build_object(
                                             'p_numbering_sequence_id'
                                            ,p_numbering_sequence_id)::jsonb
                                    ,p_context_data   =>
                                        jsonb_build_object(
                                             'var_context_data',  to_jsonb(var_context_data))),
                        ERRCODE = 'PM006',
                        SCHEMA  = 'ms_syst_data',
                        TABLE   = 'syst_numbering_sequence_values';

        END CASE;

    ELSIF
        sign(var_context_data.value_increment) = 1 AND
        var_context_data.value_increment > upper(var_context_data.allowed_value_range) -
                                           var_context_data.next_value
    THEN

        var_new_next_value := upper(var_context_data.allowed_value_range) + 1;

    ELSIF
        sign(var_context_data.value_increment) = -1 AND
        abs(var_context_data.value_increment) > var_context_data.next_value -
                                                lower(var_context_data.allowed_value_range)
    THEN

        var_new_next_value := lower(var_context_data.allowed_value_range) - 1;

    ELSE

        var_new_next_value := var_context_data.next_value + var_context_data.value_increment;

    END IF;

    UPDATE ms_syst_data.syst_numbering_sequence_values SET
        next_value = var_new_next_value
    WHERE id = var_context_data.id;

    RETURN var_return_value;

END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION
    ms_syst_priv.get_next_sequence_value( p_numbering_sequence_id uuid )
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION
    ms_syst_priv.get_next_sequence_value( p_numbering_sequence_id uuid )
    FROM public;
GRANT EXECUTE ON FUNCTION
    ms_syst_priv.get_next_sequence_value( p_numbering_sequence_id uuid )
    TO <%= ms_owner %>;

DO
$DOCUMENTATION$
DECLARE
    -- Function
    var_comments_config ms_syst_priv.comments_config_function;

    -- Parameters
    var_p_numbering_sequence_id ms_syst_priv.comments_config_function_param;

BEGIN

    --
    -- Function Config
    --

    var_comments_config.function_schema := 'ms_syst_priv';
    var_comments_config.function_name   := 'get_next_sequence_value';

    var_comments_config.description :=
$DOC$Returns the next value for the requested numbering sequence.$DOC$;

    var_comments_config.general_usage :=
$DOC$If the sequence has exhausted all values in the allowed range of values, this
function will either cycle or error depending on the value of the prevailing
`ms_syst_data.syst_numbering_sequences.cycle_policy` column value.  The cycle
policy option values are:

  * `cycle`

    The numbering sequence will reset to the start of the sequence, effectively
    rolling over.

  * `error`

    An exception is raised whenever an attempt is made to get a value from the
    numbering sequence.$DOC$;

    --
    -- Parameter Configs
    --

    var_p_numbering_sequence_id.param_name := 'p_numbering_sequence_id';
    var_p_numbering_sequence_id.description :=
$DOC$The record ID of the numbering sequence from which to draw the next value.$DOC$;

    var_comments_config.params :=
        ARRAY [ var_p_numbering_sequence_id ]::ms_syst_priv.comments_config_function_param[];

    PERFORM ms_syst_priv.generate_comments_function( var_comments_config );

END;
$DOCUMENTATION$;
