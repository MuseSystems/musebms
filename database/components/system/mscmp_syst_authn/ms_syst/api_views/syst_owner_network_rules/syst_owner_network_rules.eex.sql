-- File:        syst_owner_network_rules.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_owner_network_rules/syst_owner_network_rules.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE VIEW ms_syst.syst_owner_network_rules AS
SELECT
    id
  , owner_id
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
FROM ms_syst_data.syst_owner_network_rules;

ALTER VIEW ms_syst.syst_owner_network_rules OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_owner_network_rules FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_owner_network_rules
    INSTEAD OF INSERT ON ms_syst.syst_owner_network_rules
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_owner_network_rules();

CREATE TRIGGER a50_trig_i_u_syst_owner_network_rules
    INSTEAD OF UPDATE ON ms_syst.syst_owner_network_rules
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_owner_network_rules();

CREATE TRIGGER a50_trig_i_d_syst_owner_network_rules
    INSTEAD OF DELETE ON ms_syst.syst_owner_network_rules
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_owner_network_rules();

COMMENT ON
    VIEW ms_syst.syst_owner_network_rules IS
$DOC$Defines firewall-like rules that are global in scope indicating which IP
addresses are allowed to attempt authentication and which are not.  This also
includes the concept of global defaults applied to new Owner IP address rules.
These rules are applied in their defined ordering after the global_network_rules
and before the instance_network_rules.

This API View allows the application to read and maintain the data according to
well defined application business rules.  Using this API view for updates to
data is the preferred method of data maintenance in the course of normal usage.

Only user maintainable values may be maintained via this API.  System created or
maintained data is not maintainable via this view.  Attempts at invalid data
maintenance via this API may result in the invalid changes being ignored or may
raise an exception.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owner_network_rules.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN  ms_syst.syst_owner_network_rules.owner_id IS
$DOC$The database identifier of the Owner record for whom the Network Rule is
being defined.

This value may only be set at record insertion time using this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owner_network_rules.ordering IS
$DOC$Defines the order in which IP rules are applied.  Lower values are applied
prior to higher values.  Note that all values of ordering should be unique
within each of the two types of rules, template and non-template types.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owner_network_rules.functional_type IS
$DOC$Indicates how the system will interpret the IP address rule.  The valid
functional types are:

    * `allow` - the rule is explicitly allowing an IP address, network, or
    range of IP addresses to continue in the authentication process.

    * `deny` - the rule is explicitly rejecting an IP address, network, or
    range of IP addresses from the authentication process.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owner_network_rules.ip_host_or_network IS
$DOC$An IPv4 or IPv6 IP address or network block expressed using standard CIDR
notation.

If this value is given you should not provide an IP host address range in the
ip_host_range_lower/ip_host_range_upper columns.  Providing range column values
when this column is not null will result in a consistency check failure.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owner_network_rules.ip_host_range_lower IS
$DOC$An IPv4 or IPv6 IP host address which is the lower bound (inclusive) of a
range of IP addresses.

If the value in this column is not null a value must also be provided for the
ip_host_range_upper column.  Both ip_host_range_lower and ip_host_range_upper
must be of the same IP family (IPv4 or IPv6).$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owner_network_rules.ip_host_range_upper IS
$DOC$An IPv4 or IPv6 IP host address which is the upper bound (inclusive) of a
range of IP addresses.

If the value in this column is not null a value must also be provided for the
ip_host_range_lower column.  Both ip_host_range_lower and ip_host_range_upper
must be of the same IP family (IPv4 or IPv6).$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owner_network_rules.ip_family IS
$DOC$
Indicates which IP family (IPv4/IPv6) for which the record defines a rule.

This value is read only from this API view.
$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owner_network_rules.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owner_network_rules.diag_role_created IS
$DOC$The database role which created the record.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owner_network_rules.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owner_network_rules.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owner_network_rules.diag_role_modified IS
$DOC$The database role which modified the record.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owner_network_rules.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owner_network_rules.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.

This value is read only from this API view.$DOC$;
