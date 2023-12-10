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

COMMENT ON FUNCTION
    ms_syst_priv.generate_command_tsvector(
        p_config          regconfig,
        p_command         text,
        p_command_aliases text[] ) IS
$DOC$Generates a tsvector value for relations which implement the "searchable
command" pattern.  Searchable commands are typically searched for the purpose of
performing user interface autocomplete operations.  Searches prioritize the
primary Command text over any defined aliases which may exist.$DOC$;
