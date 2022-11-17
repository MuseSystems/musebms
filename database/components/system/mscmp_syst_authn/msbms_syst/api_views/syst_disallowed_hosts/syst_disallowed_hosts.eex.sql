-- File:        syst_disallowed_hosts.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/msbms_syst/api_views/syst_disallowed_hosts/syst_disallowed_hosts.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE VIEW msbms_syst.syst_disallowed_hosts AS
SELECT
    id
  , host_address
  , diag_timestamp_created
  , diag_role_created
  , diag_timestamp_modified
  , diag_wallclock_modified
  , diag_role_modified
  , diag_row_version
  , diag_update_count
FROM msbms_syst_data.syst_disallowed_hosts;

ALTER VIEW msbms_syst.syst_disallowed_hosts OWNER TO <%= msbms_owner %>;

REVOKE ALL ON TABLE msbms_syst.syst_disallowed_hosts FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_disallowed_hosts
    INSTEAD OF INSERT ON msbms_syst.syst_disallowed_hosts
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst.trig_i_i_syst_disallowed_hosts();

CREATE TRIGGER a50_trig_i_u_syst_disallowed_hosts
    INSTEAD OF UPDATE ON msbms_syst.syst_disallowed_hosts
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst.trig_i_u_syst_disallowed_hosts();

CREATE TRIGGER a50_trig_i_d_syst_disallowed_hosts
    INSTEAD OF DELETE ON msbms_syst.syst_disallowed_hosts
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst.trig_i_d_syst_disallowed_hosts();

COMMENT ON
    VIEW msbms_syst.syst_disallowed_hosts IS
$DOC$A listing of IP addresses which are not allowed to attempt authentication.  This
registry differs from the syst_*_network_rules tables in that IP addresses here
are registered as the result of automatic system heuristics whereas the network
rules are direct expressions of system administrator intent.  The timing between
these two mechanisms is also different in that records in this table are
evaluated prior to an authentication attempt and most network rules are
processed in the authentication attempt sequence.

This API View allows the application to read and maintain the data according to
well defined application business rules.  Using this API view for updates to
data is the preferred method of data maintenance in the course of normal usage.

Only user maintainable values may be maintained via this API.  System created or
maintained data is not maintainable via this view.  Attempts at invalid data
maintenance via this API may result in the invalid changes being ignored or may
raise an exception.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_disallowed_hosts.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_disallowed_hosts.host_address IS
$DOC$The IP address of the host disallowed from attempting to authenticate Access
Accounts.

The value in this column must be set on insert, but may not be updated later via
this API view.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_disallowed_hosts.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_disallowed_hosts.diag_role_created IS
$DOC$The database role which created the record.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_disallowed_hosts.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_disallowed_hosts.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_disallowed_hosts.diag_role_modified IS
$DOC$The database role which modified the record.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_disallowed_hosts.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_disallowed_hosts.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.

This value is read only from this API view.$DOC$;
