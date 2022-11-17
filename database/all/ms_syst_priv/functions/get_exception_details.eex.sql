--
-- Returns exception details based on the passed parameters represented as a pretty-printed JSON
-- object.  The returned value is intended to standardize the details related to RAISEd exceptions
-- and be suitable for use in setting the RAISE DETAILS variable.
--

CREATE OR REPLACE FUNCTION
    ms_syst_priv.get_exception_details(p_proc_schema    text
                                         ,p_proc_name      text
                                         ,p_exception_name text
                                         ,p_errcode        text
                                         ,p_param_data     jsonb
                                         ,p_context_data   jsonb)
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
                ,'exception_name',        p_exception_name
                ,'sqlstate',              p_errcode
                ,'parameters',            p_param_data
                ,'context',               p_context_data
                ,'transaction_timestamp', now()
                ,'wallclock_timestamp',   clock_timestamp()));

$BODY$
LANGUAGE sql VOLATILE;

ALTER FUNCTION ms_syst_priv.get_exception_details(p_proc_schema    text
                                                    ,p_proc_name      text
                                                    ,p_exception_name text
                                                    ,p_errcode        text
                                                    ,p_param_data     jsonb
                                                    ,p_context_data   jsonb)
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION
    ms_syst_priv.get_exception_details(p_proc_schema    text
                                          ,p_proc_name      text
                                          ,p_exception_name text
                                          ,p_errcode        text
                                          ,p_param_data     jsonb
                                          ,p_context_data   jsonb)
    FROM public;

GRANT EXECUTE ON FUNCTION
    ms_syst_priv.get_exception_details( p_proc_schema    text
                                          ,p_proc_name      text
                                          ,p_exception_name text
                                          ,p_errcode        text
                                          ,p_param_data     jsonb
                                          ,p_context_data   jsonb)
    TO <%= ms_owner %>;


COMMENT ON FUNCTION
    ms_syst_priv.get_exception_details(p_proc_schema    text
                                          ,p_proc_name      text
                                          ,p_exception_name text
                                          ,p_errcode        text
                                          ,p_param_data     jsonb
                                          ,p_context_data   jsonb) IS
$DOC$Returns exception details based on the passed parameters represented as a pretty-printed JSON
object.  The returned value is intended to standardize the details related to RAISEd exceptions and
be suitable for use in setting the RAISE DETAILS variable. $DOC$;
