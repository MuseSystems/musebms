-- File:        syst_instance_network_rules.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_instance_network_rules/syst_instance_network_rules.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE VIEW ms_syst.syst_instance_network_rules AS
SELECT
    id
  , instance_id
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
FROM ms_syst_data.syst_instance_network_rules;

ALTER VIEW ms_syst.syst_instance_network_rules OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_instance_network_rules FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_instance_network_rules
    INSTEAD OF INSERT ON ms_syst.syst_instance_network_rules
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_instance_network_rules();

CREATE TRIGGER a50_trig_i_u_syst_instance_network_rules
    INSTEAD OF UPDATE ON ms_syst.syst_instance_network_rules
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_instance_network_rules();

CREATE TRIGGER a50_trig_i_d_syst_instance_network_rules
    INSTEAD OF DELETE ON ms_syst.syst_instance_network_rules
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_instance_network_rules();

DO
$DOCUMENTATION$
DECLARE
    -- View
    v_view_config ms_syst_priv.comments_config_apiview;

    -- View Columns
    v_instance_id         ms_syst_priv.comments_config_apiview_column;
    v_ordering            ms_syst_priv.comments_config_apiview_column;
    v_functional_type     ms_syst_priv.comments_config_apiview_column;
    v_ip_host_or_network  ms_syst_priv.comments_config_apiview_column;
    v_ip_host_range_lower ms_syst_priv.comments_config_apiview_column;
    v_ip_host_range_upper ms_syst_priv.comments_config_apiview_column;
    v_ip_family           ms_syst_priv.comments_config_apiview_column;

BEGIN

    --
    -- API View Config
    --

    v_view_config.table_schema := 'ms_syst_data';
    v_view_config.table_name   := 'syst_instance_network_rules';
    v_view_config.view_schema  := 'ms_syst';
    v_view_config.view_name    := 'syst_instance_network_rules';

    --
    -- Column Configs
    --

    v_instance_id.column_name      := 'instance_id';
    v_instance_id.required         := TRUE;
    v_instance_id.unique_values    := FALSE;
    v_instance_id.user_update      := FALSE;
    v_instance_id.supplemental     :=
$DOC$This column is part of a composite key.  The combined values of `instance_id`
and `ordering` must be unique.$DOC$;

    v_ordering.column_name      := 'ordering';
    v_ordering.required         := TRUE;
    v_ordering.supplemental     :=
$DOC$This column is part of a composite key.  The combined values of `instance_id`
and `ordering` must be unique.$DOC$;

    v_functional_type.column_name      := 'functional_type';
    v_functional_type.required         := TRUE;

    v_ip_host_or_network.column_name      := 'ip_host_or_network';

    v_ip_host_range_lower.column_name      := 'ip_host_range_lower';

    v_ip_host_range_upper.column_name      := 'ip_host_range_upper';

    v_ip_family.column_name      := 'ip_family';
    v_ip_family.user_insert      := FALSE;
    v_ip_family.user_update      := FALSE;
    v_ip_family.override_description :=
$DOC$Indicates which IP family (IPv4/IPv6) for which the record defines a rule.$DOC$;

    v_view_config.columns :=
        ARRAY [
              v_instance_id
            , v_ordering
            , v_functional_type
            , v_ip_host_or_network
            , v_ip_host_range_lower
            , v_ip_host_range_upper
            , v_ip_family
            ]::ms_syst_priv.comments_config_apiview_column[];

    PERFORM ms_syst_priv.generate_comments_apiview( v_view_config );

END;
$DOCUMENTATION$;
