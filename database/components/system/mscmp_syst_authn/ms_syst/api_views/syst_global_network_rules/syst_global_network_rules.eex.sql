-- File:        syst_global_network_rules.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_global_network_rules/syst_global_network_rules.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE VIEW ms_syst.syst_global_network_rules AS
SELECT
    id
  , ordering
  , functional_type
  , ip_host_or_network
  , ip_host_range_lower
  , ip_host_range_upper
  , family( coalesce( ip_host_or_network, ip_host_range_lower ) ) AS ip_family
  , diag_timestamp_created
  , diag_role_created
  , diag_timestamp_modified
  , diag_wallclock_modified
  , diag_role_modified
  , diag_row_version
  , diag_update_count
FROM ms_syst_data.syst_global_network_rules;

ALTER VIEW ms_syst.syst_global_network_rules OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_global_network_rules FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_global_network_rules
    INSTEAD OF INSERT ON ms_syst.syst_global_network_rules
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_global_network_rules();

CREATE TRIGGER a50_trig_i_u_syst_global_network_rules
    INSTEAD OF UPDATE ON ms_syst.syst_global_network_rules
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_global_network_rules();

CREATE TRIGGER a50_trig_i_d_syst_global_network_rules
    INSTEAD OF DELETE ON ms_syst.syst_global_network_rules
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_global_network_rules();

DO
$DOCUMENTATION$
DECLARE
    -- View
    var_view_config ms_syst_priv.comments_config_apiview;

    -- View Columns
    var_ordering            ms_syst_priv.comments_config_apiview_column;
    var_functional_type     ms_syst_priv.comments_config_apiview_column;
    var_ip_host_or_network  ms_syst_priv.comments_config_apiview_column;
    var_ip_host_range_lower ms_syst_priv.comments_config_apiview_column;
    var_ip_host_range_upper ms_syst_priv.comments_config_apiview_column;
    var_ip_family           ms_syst_priv.comments_config_apiview_column;

BEGIN

    --
    -- API View Config
    --

    var_view_config.table_schema := 'ms_syst_data';
    var_view_config.table_name   := 'syst_global_network_rules';
    var_view_config.view_schema  := 'ms_syst';
    var_view_config.view_name    := 'syst_global_network_rules';

    --
    -- Column Configs
    --

    var_ordering.column_name      := 'ordering';
    var_ordering.required         := TRUE;
    var_ordering.unique_values    := TRUE;

    var_functional_type.column_name      := 'functional_type';
    var_functional_type.required         := TRUE;

    var_ip_host_or_network.column_name      := 'ip_host_or_network';

    var_ip_host_range_lower.column_name      := 'ip_host_range_lower';

    var_ip_host_range_upper.column_name      := 'ip_host_range_upper';

    var_ip_family.column_name      := 'ip_family';
    var_ip_family.user_insert      := FALSE;
    var_ip_family.user_update      := FALSE;
    var_ip_family.override_description :=
$DOC$Indicates which IP family (IPv4/IPv6) for which the record defines a rule.$DOC$;

    var_view_config.columns :=
        ARRAY [
              var_ordering
            , var_functional_type
            , var_ip_host_or_network
            , var_ip_host_range_lower
            , var_ip_host_range_upper
            , var_ip_family
            ]::ms_syst_priv.comments_config_apiview_column[];

    PERFORM ms_syst_priv.generate_comments_apiview( var_view_config );

END;
$DOCUMENTATION$;
