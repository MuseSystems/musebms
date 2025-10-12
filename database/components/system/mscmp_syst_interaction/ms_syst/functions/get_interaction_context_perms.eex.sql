CREATE OR REPLACE FUNCTION
    ms_syst.get_interaction_context_perms(
        p_context_id   uuid DEFAULT NULL::uuid,
        p_context_name text DEFAULT NULL::text
    )
    RETURNS
        table
            ( context_name           text,
              context_perm           text,
              context_perms_required text[],
              context_actions        jsonb,
              context_fields         jsonb )
AS
$BODY$

-- File:        get_interaction_context_perms.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_interaction/ms_syst/functions/get_interaction_context_perms.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

SELECT
    ms_syst_priv.get_interaction_context_perms(
        p_context_id,
        p_context_name);

$BODY$
    LANGUAGE sql
    STABLE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION
    ms_syst.get_interaction_context_perms(p_context_id uuid, p_context_name text)
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION
    ms_syst.get_interaction_context_perms(p_context_id uuid, p_context_name text)
    FROM public;

GRANT EXECUTE ON FUNCTION
    ms_syst.get_interaction_context_perms(p_context_id uuid, p_context_name text)
    TO <%= ms_owner %>;

DO
$DOCUMENTATION$
DECLARE
    -- Function
    v_comments_config ms_syst_priv.comments_config_function;

    -- Parameters

BEGIN

    --
    -- Function Config
    --

    v_comments_config.function_schema := 'ms_syst';
    v_comments_config.function_name   := 'get_interaction_context_perms';

    v_comments_config.trigger_function := FALSE;
    v_comments_config.trigger_timing   := ARRAY [ ]::text[ ];
    v_comments_config.trigger_ops      := ARRAY [ ]::text[ ];

    v_comments_config.description :=
$DOC$$DOC$;

    v_comments_config.general_usage :=
$DOC$$DOC$;

    --
    -- Parameter Configs
    --



    v_comments_config.params :=
        ARRAY [ ]::ms_syst_priv.comments_config_function_param[];

    PERFORM ms_syst_priv.generate_comments_function( v_comments_config );

END;
$DOCUMENTATION$;
