-- File:        syst_global_network_rules.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst_data/syst_global_network_rules/syst_global_network_rules.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TABLE ms_syst_data.syst_global_network_rules
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v7( )
        CONSTRAINT syst_global_network_rules_pk PRIMARY KEY
    ,ordering
        integer
        NOT NULL
        CONSTRAINT syst_global_network_rules_ordering_udx
            UNIQUE DEFERRABLE INITIALLY DEFERRED
    ,functional_type
        text
        NOT NULL
        CONSTRAINT syst_global_network_rules_functional_type_chk
            CHECK ( functional_type IN ( 'allow', 'deny' ) )
    ,ip_host_or_network
        inet
    ,ip_host_range_lower
        inet
    ,ip_host_range_upper
        inet
    ,CONSTRAINT syst_global_network_rules_host_or_range_chk
        CHECK (
            ( ip_host_or_network IS NOT NULL AND
                ip_host_range_lower IS NULL AND
                ip_host_range_upper IS NULL) OR
            ( ip_host_or_network IS NULL AND
                ip_host_range_lower IS NOT NULL AND
                ip_host_range_upper IS NOT NULL)
            )
    ,CONSTRAINT syst_global_network_rules_ip_range_family_chk
        CHECK (
            family(ip_host_range_lower) = family(ip_host_range_upper)
            )
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
);

ALTER TABLE ms_syst_data.syst_global_network_rules OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_global_network_rules FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_global_network_rules TO <%= ms_owner %>;

CREATE TRIGGER b50_trig_a_iu_syst_global_network_rule_ordering
    AFTER INSERT OR UPDATE ON ms_syst_data.syst_global_network_rules
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_data.trig_a_iu_syst_global_network_rule_ordering();

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_global_network_rules
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

DO
$DOCUMENTATION$
DECLARE
    -- Table
    var_comments_config ms_syst_priv.comments_config_table;

    -- Columns
    var_ordering            ms_syst_priv.comments_config_table_column;
    var_functional_type     ms_syst_priv.comments_config_table_column;
    var_ip_host_or_network  ms_syst_priv.comments_config_table_column;
    var_ip_host_range_lower ms_syst_priv.comments_config_table_column;
    var_ip_host_range_upper ms_syst_priv.comments_config_table_column;

BEGIN

    --
    -- Table Config
    --

    var_comments_config.table_schema := 'ms_syst_data';
    var_comments_config.table_name   := 'syst_global_network_rules';

    var_comments_config.description :=
$DOC$Defines firewall-like rules that are global in scope indicating which IP
addresses are allowed to attempt authentication and which are not.  This also
includes the concept of global defaults applied to new Owner IP address rules.
These rules are applied in their defined ordering prior to all other rule sets.$DOC$;

    --
    -- Column Configs
    --

    var_ordering.column_name := 'ordering';
    var_ordering.description :=
$DOC$Defines the order in which IP rules are applied.  Lower values are applied
prior to higher values.$DOC$;
    var_ordering.general_usage :=
$DOC$All records are ordered using unique ordering values within each owner value.
When a new Owner Network Rule is inserted with the ordering value of an
existing Owner Network Rule record for the same Owner, the system will assume
the new record should be "inserted before" the existing record.  Therefore the
existing record will be reordered behind the new record by incrementing the
existing record's ordering value by one.  This reordering process happens
recursively until there are no ordering value conflicts for any of an Owner's
Network Rule records.$DOC$;

    var_functional_type.column_name := 'functional_type';
    var_functional_type.description :=
$DOC$Indicates how the system will interpret the IP address rule.
$DOC$;
    var_functional_type.general_usage :=
$DOC$The valid functional types are:

  * `allow` - the rule is explicitly allowing an IP address, network, or range
    of IP addresses to continue in the authentication process.

  * `deny` - the rule is explicitly rejecting an IP address, network, or range
    of IP addresses from the authentication process.$DOC$;


    var_ip_host_or_network.column_name := 'ip_host_or_network';
    var_ip_host_or_network.description :=
$DOC$An IPv4 or IPv6 IP address or network block expressed using standard CIDR
notation.$DOC$;

    var_ip_host_or_network.general_usage :=
$DOC$If this value is given you should not provide an IP host address range in the
ip_host_range_lower/ip_host_range_upper columns.  Providing range column values
when this column is not null will result in a consistency check failure.$DOC$;

    var_ip_host_range_lower.column_name := 'ip_host_range_lower';
    var_ip_host_range_lower.description :=
$DOC$An IPv4 or IPv6 IP host address which is the lower bound (inclusive) of a
range of IP addresses.$DOC$;

    var_ip_host_range_lower.general_usage :=
$DOC$If the value in this column is not null a value must also be provided for the
ip_host_range_upper column.  Both ip_host_range_lower and ip_host_range_upper
must be of the same IP family (IPv4 or IPv6).$DOC$;

    var_ip_host_range_upper.column_name := 'ip_host_range_upper';
    var_ip_host_range_upper.description :=
$DOC$An IPv4 or IPv6 IP host address which is the upper bound (inclusive) of a
range of IP addresses.$DOC$;

    var_ip_host_range_upper.general_usage :=
$DOC$If the value in this column is not null a value must also be provided for the
ip_host_range_lower column.  Both ip_host_range_lower and ip_host_range_upper
must be of the same IP family (IPv4 or IPv6).$DOC$;

    var_comments_config.columns :=
        ARRAY [
              var_ordering
            , var_functional_type
            , var_ip_host_or_network
            , var_ip_host_range_lower
            , var_ip_host_range_upper
            ]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( var_comments_config );

END;
$DOCUMENTATION$;
