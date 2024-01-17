CREATE OR REPLACE FUNCTION
    ms_syst.get_applied_network_rule(
        p_host_addr         inet,
        p_instance_id       uuid DEFAULT NULL,
        p_instance_owner_id uuid DEFAULT NULL )
    RETURNS table
            (
                precedence          text,
                network_rule_id     uuid,
                functional_type     text,
                ip_host_or_network  inet,
                ip_host_range_lower inet,
                ip_host_range_upper inet
            )
AS
$BODY$

-- File:        get_applied_network_rule.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/functions/get_applied_network_rule.eex.sql
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
        precedence
      , network_rule_id
      , functional_type
      , ip_host_or_network
      , ip_host_range_lower
      , ip_host_range_upper
    FROM
        ms_syst_priv.get_applied_network_rule(
              p_host_addr         => p_host_addr
            , p_instance_id       => p_instance_id
            , p_instance_owner_id => p_instance_owner_id);

$BODY$
    LANGUAGE sql
    STABLE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION
    ms_syst.get_applied_network_rule(
        p_host_addr         inet,
        p_instance_id       uuid,
        p_instance_owner_id uuid )
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION
    ms_syst.get_applied_network_rule(
        p_host_addr         inet,
        p_instance_id       uuid,
        p_instance_owner_id uuid )
    FROM PUBLIC;

GRANT EXECUTE ON FUNCTION
    ms_syst.get_applied_network_rule(
        p_host_addr         inet,
        p_instance_id       uuid,
        p_instance_owner_id uuid )
    TO <%= ms_owner %>;

DO
$DOCUMENTATION$
BEGIN
    PERFORM
        ms_syst_priv.generate_comments_copy_function(
            p_source_schema => 'ms_syst_priv',
            p_source_name   => 'get_applied_network_rule',
            p_target_schema => 'ms_syst',
            p_target_name   => 'get_applied_network_rule'
        );
END;
$DOCUMENTATION$;
