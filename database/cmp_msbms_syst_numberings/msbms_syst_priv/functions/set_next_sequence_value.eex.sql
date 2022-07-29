CREATE OR REPLACE FUNCTION msbms_syst_priv.set_next_sequence_values(p_numbering_sequence_id uuid, p_new_value bigint)
RETURNS void AS
$BODY$

-- File:        set_next_sequence_value.eex.sql
-- Location:    musebms/database/cmp_msbms_syst_numberings/msbms_syst_priv/functions/set_next_sequence_value.eex.sql
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
    var_context_data record;
BEGIN

    SELECT INTO var_context_data
         NOT p_new_value @> allowed_value_range AS new_value_disallowed
        ,allowed_value_range
    FROM msbms_syst_data.syst_numbering_sequences sns
        JOIN msbms_syst_data.syst_numbering_sequence_values snsv
            ON snsv.id = sns.id
    WHERE sns.id = p_numbering_sequence_id
    FOR UPDATE OF msbms_syst_data.syst_numbering_sequence_values;


    IF var_context_data.new_value_disallowed THEN

        RAISE EXCEPTION
            USING
                MESSAGE = 'The requested new value for the numbering sequence is outside of the ' ||
                          'acceptable range of values. ',
                DETAIL  = msbms_syst_priv.get_exception_details(
                             p_proc_schema    => 'msbms_syst_priv'
                            ,p_proc_name      => 'set_next_sequence_value'
                            ,p_exception_name => 'numbering_sequence_out_of_range'
                            ,p_errcode        => 'PM007'
                            ,p_param_data     =>
                                jsonb_build_object(
                                     'p_numbering_sequence_id'
                                    ,p_numbering_sequence_id
                                    ,'p_new_value'
                                    ,p_new_value)::jsonb
                            ,p_context_data   =>
                                jsonb_build_object(
                                     'var_context_data',  to_jsonb(var_context_data))),
                ERRCODE = 'PM007',
                SCHEMA  = 'msbms_syst_data',
                TABLE   = 'syst_numbering_sequence_values';

    END IF;

    UPDATE msbms_syst_data.syst_numbering_sequence_values SET
        next_value = p_new_value
    WHERE id = p_numbering_sequence_id;

END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION
    msbms_syst_priv.set_next_sequence_values( uuid,  bigint )
    OWNER TO <%= msbms_owner %>;

REVOKE EXECUTE ON FUNCTION
    msbms_syst_priv.set_next_sequence_values( uuid,  bigint ) FROM public;
GRANT EXECUTE ON FUNCTION
    msbms_syst_priv.set_next_sequence_values( uuid,  bigint ) TO <%= msbms_owner %>;



COMMENT ON FUNCTION
    msbms_syst_priv.set_next_sequence_values( uuid, bigint ) IS
$DOC$Set the value of a numbering sequence.  Using this function ensures that the
targeted new value is within the acceptable ranges of the sequence.  Note that
this function is only needed when setting the value to an entirely new value and
it is not needed after a value has been retrieved from the numbering sequence.$DOC$;
