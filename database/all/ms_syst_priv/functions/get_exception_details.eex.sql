--
-- Returns exception details based on the passed parameters represented as a pretty-printed JSON
-- object.  The returned value is intended to standardize the details related to RAISEd exceptions
-- and be suitable for use in setting the RAISE DETAILS variable.
--

CREATE OR REPLACE FUNCTION
    ms_syst_priv.get_exception_details(
        p_proc_schema    text,
        p_proc_name      text,
        p_param_data     jsonb,
        p_context_data   jsonb )
RETURNS text AS
$BODY$

-- File:        get_exception_details.eex.sql
-- Location:    musebms/database/all/ms_syst_priv/functions/get_exception_details.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems


    SELECT
        jsonb_pretty(
            jsonb_build_object(
                 'procedure_schema',      p_proc_schema
                ,'procedure_name',        p_proc_name
                ,'parameters',            p_param_data
                ,'context',               p_context_data
                ,'transaction_timestamp', now()
                ,'wallclock_timestamp',   clock_timestamp()));

$BODY$
LANGUAGE sql VOLATILE;

ALTER FUNCTION
    ms_syst_priv.get_exception_details(
        p_proc_schema    text,
        p_proc_name      text,
        p_param_data     jsonb,
        p_context_data   jsonb )
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION
    ms_syst_priv.get_exception_details(
        p_proc_schema    text,
        p_proc_name      text,
        p_param_data     jsonb,
        p_context_data   jsonb )
    FROM public;

GRANT EXECUTE ON FUNCTION
    ms_syst_priv.get_exception_details(
        p_proc_schema    text,
        p_proc_name      text,
        p_param_data     jsonb,
        p_context_data   jsonb )
    TO <%= ms_owner %>;

DO
$DOCUMENTATION$
DECLARE
    -- Function
    v_comments_config ms_syst_priv.comments_config_function;

    -- Parameters
    v_p_proc_schema    ms_syst_priv.comments_config_function_param;
    v_p_proc_name      ms_syst_priv.comments_config_function_param;
    v_p_param_data     ms_syst_priv.comments_config_function_param;
    v_p_context_data   ms_syst_priv.comments_config_function_param;
BEGIN

    --
    -- Function Config
    --

    v_comments_config.function_schema := 'ms_syst_priv';
    v_comments_config.function_name   := 'get_exception_details';

    v_comments_config.description :=
$DOC$Returns exception details based on the passed parameters represented as a
pretty-printed JSON object.  The returned value is intended to standardize the
details related to `RAISE`d exceptions and be suitable for use in setting the
`RAISE DETAILS` variable.$DOC$;

    --
    -- Parameter Configs
    --

    v_p_proc_schema.param_name := 'p_proc_schema';
    v_p_proc_schema.description :=
$DOC$The schema name hosting the function or store procedure which raised the
exception.$DOC$;

    v_p_proc_name.param_name := 'p_proc_name';
    v_p_proc_name.description :=
$DOC$The name of the process which raised the exception.$DOC$;

    v_p_param_data.param_name := 'p_param_data';
    v_p_param_data.required := FALSE;
    v_p_param_data.description :=
$DOC$A `jsonb` object where the keys are relevant parameters.$DOC$;

    v_p_context_data.param_name := 'p_context_data';
    v_p_context_data.required := FALSE;
    v_p_context_data.description :=
$DOC$A `jsonb` object encapsulating relevant data which might help in
interpreting the exception, if such data exists.$DOC$;

    v_comments_config.params :=
        ARRAY [
              v_p_proc_schema
            , v_p_proc_name
            , v_p_param_data
            , v_p_context_data
            ]::ms_syst_priv.comments_config_function_param[];

    PERFORM ms_syst_priv.generate_comments_function( v_comments_config );

END;
$DOCUMENTATION$;
