CREATE OR REPLACE FUNCTION
    ms_syst_priv.get_applied_network_rule(
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
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst_priv/functions/get_applied_network_rule.eex.sql
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
        rule.precedence
      , rule.network_rule_id
      , rule.functional_type
      , rule.ip_host_or_network
      , rule.ip_host_range_lower
      , rule.ip_host_range_upper
    FROM ( SELECT
               1            AS precedence_sort
             , 'disallowed' AS precedence
             , 1            AS ordering
             , id           AS network_rule_id
             , 'deny'       AS functional_type
             , host_address AS ip_host_or_network
             , NULL         AS ip_host_range_lower
             , NULL         AS ip_host_range_upper
           FROM ms_syst_data.syst_disallowed_hosts
           WHERE host_address = p_host_addr
           UNION
           SELECT
               2        AS precedence_sort
             , 'global' AS precedence
             , ordering
             , id       AS network_rule_id
             , functional_type
             , ip_host_or_network
             , ip_host_range_lower
             , ip_host_range_upper
           FROM ms_syst_data.syst_global_network_rules
           WHERE
               ( ip_host_or_network >>= p_host_addr OR
                 p_host_addr BETWEEN ip_host_range_lower AND ip_host_range_upper )
           UNION
           SELECT
               3          AS precedence_sort
             , 'instance' AS precedence
             , ordering
             , id         AS network_rule_id
             , functional_type
             , ip_host_or_network
             , ip_host_range_lower
             , ip_host_range_upper
           FROM ms_syst_data.syst_instance_network_rules
           WHERE
                 instance_id = p_instance_id
             AND ( ip_host_or_network >>= p_host_addr OR
                   p_host_addr BETWEEN ip_host_range_lower AND ip_host_range_upper )
           UNION
           SELECT
               4                AS precedence_sort
             , 'instance_owner' AS precedence
             , ordering
             , id               AS network_rule_id
             , functional_type
             , ip_host_or_network
             , ip_host_range_lower
             , ip_host_range_upper
           FROM ms_syst_data.syst_owner_network_rules
           WHERE
                   owner_id = coalesce( p_instance_owner_id, ( SELECT owner_id
                                                               FROM ms_syst_data.syst_instances
                                                               WHERE id = p_instance_id ) )
             AND   ( ip_host_or_network >>= p_host_addr OR
                     p_host_addr BETWEEN ip_host_range_lower AND ip_host_range_upper )
           UNION
           SELECT
               5                 AS precedence_sort
             , 'implied'         AS precedence
             , 1                 AS ordering
             , NULL              AS network_rule_id
             , 'allow'           AS functional_type
             , '0.0.0.0/0'::inet AS ip_host_or_network
             , NULL              AS ip_host_range_lower
             , NULL              AS ip_host_range_upper
           ORDER BY precedence_sort, ordering
           LIMIT 1 ) rule;

$BODY$
LANGUAGE sql STABLE;

ALTER FUNCTION
    ms_syst_priv.get_applied_network_rule(
        p_host_addr         inet,
        p_instance_id       uuid,
        p_instance_owner_id uuid )
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION
    ms_syst_priv.get_applied_network_rule(
        p_host_addr         inet,
        p_instance_id       uuid,
        p_instance_owner_id uuid )
    FROM PUBLIC;

GRANT EXECUTE ON FUNCTION
    ms_syst_priv.get_applied_network_rule(
        p_host_addr         inet,
        p_instance_id       uuid,
        p_instance_owner_id uuid )
    TO <%= ms_owner %>;

DO
$DOCUMENTATION$
DECLARE
    -- Function
    var_comments_config ms_syst_priv.comments_config_function;

    -- Parameters
    var_p_host_addr         ms_syst_priv.comments_config_function_param;
    var_p_instance_id       ms_syst_priv.comments_config_function_param;
    var_p_instance_owner_id ms_syst_priv.comments_config_function_param;
BEGIN

    --
    -- Function Config
    --

    var_comments_config.function_schema := 'ms_syst_priv';
    var_comments_config.function_name   := 'get_applied_network_rule';

    var_comments_config.description :=
$DOC$Applies all of the applicable network rules for a host and returns the governing
record for the identified host.

The returned rule is chosen by identifying which rules apply to the host based
on the provided Instance related parameters and then limiting the return to the
rule with the highest precedence.  Currently the precedence is defined as:

  1. Disallowed Hosts: Globally disallowed or "banned" hosts are always checked
     first and no later rule can override the denial.  Only removing the host
     from the syst_disallowed_hosts table can reverse this denial.

  2. Global Rules: These are rules applied to all Instances without exception.

  3. Instance Rules: Rules defined by Instance Owners and are the most granular
     rule level available (p_instance_id).

  4. Instance Owner Rules: Applied to all Instances owned by the identified
     Owner (p_instance_owner_id).

  5. Global Implied Default Rule: When no explicitly defined network has been
     found for a host this rule will apply implicitly.  The current rule
     grants access from any host.$DOC$;

    var_comments_config.general_usage :=
$DOC$This function returns the best matching rule for the provided parameters.  This
means that when `p_host_addr` is provided but neither of `p_instance_id` or
`p_instance_owner_id` are provided, the host can only be evaluated against the
Disallowed Hosts and the Global Network Rules which isn't sufficient for a
complete validation of a host's access to an Instance; such incomplete checks
can be useful to avoid more expensive authentication processes later if the host
is just going to be denied access due to global network rules.

Providing only `p_instance_owner_id` will include the Global and Owner defined
rules, but not the Instance specific rules.  If `p_instance_id` is provided that
is sufficient that is sufficient for testing all the applicable rules since the
Instance Owner ID can be derived using just `p_instance_id` parameter.$DOC$;

    --
    -- Parameter Configs
    --

    var_p_host_addr.param_name := 'p_host_addr';
    var_p_host_addr.description :=
$DOC$The host IP address for which to retrieve a network rule to apply.$DOC$;

    var_p_instance_id.param_name    := 'p_instance_id';
    var_p_instance_id.required      := FALSE;
    var_p_instance_id.default_value := '`NULL`';
    var_p_instance_id.description   :=
$DOC$The record `id` of the Instance that the host is attempting to access.

Note that `NULL` is a valid value subject to the conditions in the function
description.$DOC$;

    var_p_instance_owner_id.param_name    := 'p_instance_owner_id';
    var_p_instance_owner_id.required      := FALSE;
    var_p_instance_owner_id.default_value := '`NULL`';
    var_p_instance_owner_id.description   :=
$DOC$The record `id` value of the Owner record which owns the Instance.

Note that `NULL` is a valid value subject to the conditions in the function
description.$DOC$;


    var_comments_config.params :=
        ARRAY [
              var_p_host_addr
            , var_p_instance_id
            , var_p_instance_owner_id
            ]::ms_syst_priv.comments_config_function_param[];

    PERFORM ms_syst_priv.generate_comments_function( var_comments_config );

END;
$DOCUMENTATION$;
