CREATE OR REPLACE FUNCTION
    ms_syst_priv.generate_command_tsvector(
        p_config          regconfig,
        p_command         text,
        p_command_aliases text[] )
RETURNS tsvector AS
$BODY$

-- File:        generate_command_tsvector.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_nav/ms_syst_priv/generate_command_tsvector.eex.sql
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
        setweight( to_tsvector( p_config, p_command ), 'A' ) ||
        setweight(
                to_tsvector(
                        p_config,
                        array_to_string( p_command_aliases, ' ' ) ), 'B' );


$BODY$
LANGUAGE sql IMMUTABLE;

ALTER FUNCTION
    ms_syst_priv.generate_command_tsvector(
        p_config          regconfig,
        p_command         text,
        p_command_aliases text[] )
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION
    ms_syst_priv.generate_command_tsvector(
        p_config          regconfig,
        p_command         text,
        p_command_aliases text[] ) FROM public;

GRANT EXECUTE ON FUNCTION
    ms_syst_priv.generate_command_tsvector(
        p_config          regconfig,
        p_command         text,
        p_command_aliases text[] ) TO <%= ms_owner %>;

DO
$DOCUMENTATION$
DECLARE
    -- Function
    var_comments_config ms_syst_priv.comments_config_function;

    -- Parameters
    var_p_config          ms_syst_priv.comments_config_function_param;
    var_p_command         ms_syst_priv.comments_config_function_param;
    var_p_command_aliases ms_syst_priv.comments_config_function_param;
BEGIN

    --
    -- Function Config
    --

    var_comments_config.function_schema := 'ms_syst_priv';
    var_comments_config.function_name   := 'generate_command_tsvector';

    var_comments_config.description :=
$DOC$Generates a tsvector value for relations which implement the "searchable
command" pattern.  Searchable commands are typically searched for the purpose of
performing user interface autocomplete operations.$DOC$;

    var_comments_config.general_usage :=
$DOC$This function is expected to be used in table definitions by generated columns
containing `tsvector` values.

Searches prioritize the primary Command text over any defined aliases which may
exist.$DOC$;

    --
    -- Parameter Configs
    --

    var_p_config.param_name := 'p_config';
    var_p_config.required := TRUE;
    var_p_config.description :=
$DOC$The name of the PostgreSQL text search configuration to apply to the generation
of `tsvector` values by this function.

See [the PostgreSQL documentation](https://www.postgresql.org/docs/current/textsearch-intro.html#TEXTSEARCH-INTRO-CONFIGURATIONS)
for more.$DOC$;

    var_p_command.param_name := 'p_command';
    var_p_command.description :=
$DOC$The primary Action Group or Action Command which receives priority in full text
navigation related searches.$DOC$;

    var_p_command_aliases.param_name := 'p_command_aliases';
    var_p_command_aliases.required := TRUE;
    var_p_command_aliases.description :=
$DOC$The Command Alias of the Action Group or Action which serve as secondary lookups
for the navigation related text search.$DOC$;

    var_comments_config.params :=
        ARRAY [
              var_p_config
            , var_p_command
            , var_p_command_aliases
            ]::ms_syst_priv.comments_config_function_param[];

    PERFORM ms_syst_priv.generate_comments_function( var_comments_config );

END;
$DOCUMENTATION$;
