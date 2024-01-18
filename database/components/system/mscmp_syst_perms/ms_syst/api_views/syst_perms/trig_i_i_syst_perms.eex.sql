CREATE OR REPLACE FUNCTION ms_syst.trig_i_i_syst_perms()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_perms.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_perms/ms_syst/api_views/syst_perms/trig_i_i_syst_perms.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

BEGIN

    INSERT INTO ms_syst_data.syst_perms
        ( internal_name
        , display_name
        , perm_functional_type_id
        , syst_defined
        , syst_description
        , user_description
        , view_scope_options
        , maint_scope_options
        , admin_scope_options
        , ops_scope_options )
    VALUES
        ( new.internal_name
        , new.display_name
        , new.perm_functional_type_id
        , FALSE
        , '(System Description Not Available)'
        , new.user_description
        , coalesce(new.view_scope_options, array['unused'])
        , coalesce(new.maint_scope_options, array['unused'])
        , coalesce(new.admin_scope_options, array['unused'])
        , coalesce(new.ops_scope_options, array['unused']) )
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_i_syst_perms()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_perms() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_perms() TO <%= ms_owner %>;

DO
$DOCUMENTATION$
DECLARE
    -- Function
    var_comments_config ms_syst_priv.comments_config_function;

BEGIN

    --
    -- Function Config
    --

    var_comments_config.function_schema := 'ms_syst';
    var_comments_config.function_name   := 'trig_i_i_syst_perms';

    var_comments_config.trigger_function := TRUE;
    var_comments_config.trigger_timing   := ARRAY [ 'i' ]::text[ ];
    var_comments_config.trigger_ops      := ARRAY [ 'i' ]::text[ ];

    var_comments_config.description :=
$DOC$Processes incoming API View requests according to globally applicable business
rules and data validation requirements.$DOC$;

    PERFORM ms_syst_priv.generate_comments_function( var_comments_config );

END;
$DOCUMENTATION$;
