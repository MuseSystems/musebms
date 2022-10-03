CREATE OR REPLACE
    FUNCTION msbms_syst.get_applied_network_rule(   p_host_addr         inet
                                                  , p_instance_id       uuid DEFAULT NULL
                                                  , p_instance_owner_id uuid DEFAULT NULL )
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
-- Location:    musebms/database/components/system/msbms_syst_authentication/msbms_syst/functions/get_applied_network_rule.eex.sql
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
        msbms_syst_priv.get_applied_network_rule(
              p_host_addr         => p_host_addr
            , p_instance_id       => p_instance_id
            , p_instance_owner_id => p_instance_owner_id);

$BODY$
    LANGUAGE sql
    STABLE
    SECURITY DEFINER
    SET search_path TO msbms_syst, pg_temp;

ALTER FUNCTION
    msbms_syst.get_applied_network_rule(
          p_host_addr         inet
        , p_instance_id       uuid
        , p_instance_owner_id uuid )
    OWNER TO <%= msbms_owner %>;

REVOKE EXECUTE ON FUNCTION
    msbms_syst.get_applied_network_rule(
          p_host_addr         inet
        , p_instance_id       uuid
        , p_instance_owner_id uuid )
    FROM PUBLIC;

GRANT EXECUTE ON FUNCTION
    msbms_syst.get_applied_network_rule(
          p_host_addr         inet
        , p_instance_id       uuid
        , p_instance_owner_id uuid )
    TO <%= msbms_owner %>;

COMMENT ON FUNCTION
    msbms_syst.get_applied_network_rule(
          p_host_addr         inet
        , p_instance_id       uuid
        , p_instance_owner_id uuid ) IS
$DOC$Applies all of the applicable network rules for a host and returns the governing
record for the identified host.

The returned rule is chosen by identifying which rules apply to the host based
on the provided Instance related parameters and then limiting the return to the
rule with the highest precedence.  Currently the precedence is defined as:

    1 - Disallowed Hosts: Globally disallowed or "banned" hosts are always
        checked first and no later rule can override the denial.  Only removing
        the host from the syst_disallowed_hosts table can reverse this denial.

    2 - Global Rules: These are rules applied to all Instances without
        exception.

    3 - Instance Rules: Rules defined by Instance Owners and are the most
        granular rule level available (p_instance_id).

    4 - Instance Owner Rules: Applied to all Instances owned by the identified
        Owner (p_instance_owner_id).

    5 - Global Implied Default Rule: When no explicitly defined network has been
        found for a host this rule will apply implicitly.  The current rule
        grants access from any host.

Finally note that this function returns the best matching rule for the provided
parameters.  This means that when p_host_addr is provided but neither of
p_instance_id or p_instance_owner_id are provided, the host can only be
evaluated against the Disallowed Hosts and the Global Network Rules which isn't
sufficient for a complete validation of a host's access to an Instance; such
incomplete checks can be useful to avoid more expensive authentication processes
later if the host is just going to be denied access due to global network rules.
Providing only p_instance_owner_id will include the Global and Owner defined
rules, but not the Instance specific rules.  If p_instance_id is provided that
is sufficient that is sufficient for testing all the applicable rules since the
Instance Owner ID can be derived using just p_instance_id parameter.$DOC$;
