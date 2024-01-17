CREATE OR REPLACE FUNCTION ms_syst.trig_i_u_syst_global_password_rules()
RETURNS trigger AS
$BODY$

-- File:        trig_i_u_syst_global_password_rules.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_global_password_rules/trig_i_u_syst_global_password_rules.eex.sql
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

    UPDATE ms_syst_data.syst_global_password_rules
    SET
        password_length        = new.password_length
      , max_age                = new.max_age
      , require_upper_case     = new.require_upper_case
      , require_lower_case     = new.require_lower_case
      , require_numbers        = new.require_numbers
      , require_symbols        = new.require_symbols
      , disallow_recently_used = new.disallow_recently_used
      , disallow_compromised   = new.disallow_compromised
      , require_mfa            = new.require_mfa
      , allowed_mfa_types      = new.allowed_mfa_types
    WHERE id = new.id
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_u_syst_global_password_rules()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_global_password_rules() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_global_password_rules() TO <%= ms_owner %>;

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
    var_comments_config.function_name   := 'trig_i_u_syst_global_password_rules';

    var_comments_config.trigger_function := TRUE;
    var_comments_config.trigger_timing   := ARRAY [ 'i' ]::text[ ];
    var_comments_config.trigger_ops      := ARRAY [ 'u' ]::text[ ];

    var_comments_config.description :=
$DOC$Processes incoming API View requests according to globally applicable business
rules and data validation requirements.$DOC$;

    PERFORM ms_syst_priv.generate_comments_function( var_comments_config );

END;
$DOCUMENTATION$;
