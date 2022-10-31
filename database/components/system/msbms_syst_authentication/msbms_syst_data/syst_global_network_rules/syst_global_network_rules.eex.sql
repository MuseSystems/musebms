-- File:        syst_global_network_rules.eex.sql
-- Location:    musebms/database/components/system/msbms_syst_authentication/msbms_syst_data/syst_global_network_rules/syst_global_network_rules.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TABLE msbms_syst_data.syst_global_network_rules
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_global_network_rules_pk PRIMARY KEY
    ,ordering
        integer
        NOT NULL
        CONSTRAINT syst_global_network_rules_ordering_udx UNIQUE
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

ALTER TABLE msbms_syst_data.syst_global_network_rules OWNER TO <%= msbms_owner %>;

REVOKE ALL ON TABLE msbms_syst_data.syst_global_network_rules FROM public;
GRANT ALL ON TABLE msbms_syst_data.syst_global_network_rules TO <%= msbms_owner %>;

CREATE TRIGGER b50_trig_a_iu_syst_global_network_rule_ordering
    AFTER INSERT OR UPDATE ON msbms_syst_data.syst_global_network_rules
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst_data.trig_a_iu_syst_global_network_rule_ordering();

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON msbms_syst_data.syst_global_network_rules
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE msbms_syst_data.syst_global_network_rules IS
$DOC$Defines firewall-like rules that are global in scope indicating which IP
addresses are allowed to attempt authentication and which are not.  This also
includes the concept of global defaults applied to new Owner IP address rules.
These rules are applied in their defined ordering prior to all other rule sets.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_global_network_rules.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_global_network_rules.ordering IS
$DOC$Defines the order in which IP rules are applied.  Lower values are applied
prior to higher values.

When a new record is inserted with an existing ordering value, it is treated as
"insert before" the existing record and the existing record's ordering is
increased by one; this reordering process is recursive until there are no more
ordering value conflicts.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_global_network_rules.functional_type IS
$DOC$Indicates how the system will interpret the IP address rule.  The valid
functional types are:

    * `allow` - the rule is explicitly allowing an IP address, network, or
    range of IP addresses to continue in the authentication process.

    * `deny` - the rule is explicitly rejecting an IP address, network, or
    range of IP addresses from the authentication process.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_global_network_rules.ip_host_or_network IS
$DOC$An IPv4 or IPv6 IP address or network block expressed using standard CIDR
notation.

If this value is given you should not provide an IP host address range in the
ip_host_range_lower/ip_host_range_upper columns.  Providing range column values
when this column is not null will result in a consistency check failure.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_global_network_rules.ip_host_range_lower IS
$DOC$An IPv4 or IPv6 IP host address which is the lower bound (inclusive) of a
range of IP addresses.

If the value in this column is not null a value must also be provided for the
ip_host_range_upper column.  Both ip_host_range_lower and ip_host_range_upper
must be of the same IP family (IPv4 or IPv6).$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_global_network_rules.ip_host_range_upper IS
$DOC$An IPv4 or IPv6 IP host address which is the upper bound (inclusive) of a
range of IP addresses.

If the value in this column is not null a value must also be provided for the
ip_host_range_lower column.  Both ip_host_range_lower and ip_host_range_upper
must be of the same IP family (IPv4 or IPv6).$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_global_network_rules.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_global_network_rules.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_global_network_rules.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_global_network_rules.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_global_network_rules.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_global_network_rules.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_global_network_rules.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
