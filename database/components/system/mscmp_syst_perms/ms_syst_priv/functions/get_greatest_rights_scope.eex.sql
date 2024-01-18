CREATE OR REPLACE FUNCTION ms_syst_priv.get_greatest_rights_scope(p_scopes text[])
RETURNS text AS
$BODY$

-- File:        get_greatest_rights_scope.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_perms/ms_syst_priv/functions/get_greatest_rights_scope.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

DECLARE
    var_resolved_scopes text[] := coalesce(p_scopes, ARRAY ['deny']::text[]);

BEGIN

    RETURN
        CASE
            WHEN 'all'        = ANY (var_resolved_scopes) THEN 'all'
            WHEN 'same_group' = ANY (var_resolved_scopes) THEN 'same_group'
            WHEN 'same_user'  = ANY (var_resolved_scopes) THEN 'same_user'
            WHEN 'unused'     = ANY (var_resolved_scopes) THEN 'unused'
            ELSE 'deny'
        END CASE;

END;
$BODY$
LANGUAGE plpgsql IMMUTABLE;

ALTER FUNCTION ms_syst_priv.get_greatest_rights_scope(p_scopes text[])
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_priv.get_greatest_rights_scope(p_scopes text[]) FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_priv.get_greatest_rights_scope(p_scopes text[]) TO <%= ms_owner %>;

DO
$DOCUMENTATION$
DECLARE
    -- Function
    var_comments_config ms_syst_priv.comments_config_function;

    -- Parameters
    var_p_scopes ms_syst_priv.comments_config_function_param;

BEGIN

    --
    -- Function Config
    --

    var_comments_config.function_schema := 'ms_syst_priv';
    var_comments_config.function_name   := 'get_greatest_rights_scope';

    var_comments_config.trigger_function := FALSE;
    var_comments_config.trigger_timing   := ARRAY [ ]::text[ ];
    var_comments_config.trigger_ops      := ARRAY [ ]::text[ ];

    var_comments_config.description :=
$DOC$Given an array of Permission Right Scopes, returns the most expansive scope
found in the array.$DOC$;

    var_comments_config.general_usage :=
$DOC$If the array is NULL the returned value is 'deny'.$DOC$;

    --
    -- Parameter Configs
    --

    var_p_scopes.param_name := 'p_scopes';
    var_p_scopes.description :=
$DOC$The array of permission scopes to test.$DOC$;


    var_comments_config.params :=
        ARRAY [ var_p_scopes ]::ms_syst_priv.comments_config_function_param[];

    PERFORM ms_syst_priv.generate_comments_function( var_comments_config );

END;
$DOCUMENTATION$;
