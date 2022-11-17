-- File:        syst_access_account_instance_assocs.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_access_account_instance_assocs/syst_access_account_instance_assocs.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE VIEW ms_syst.syst_access_account_instance_assocs AS
SELECT
    id
  , access_account_id
  , instance_id
  , access_granted
  , invitation_issued
  , invitation_expires
  , invitation_declined
  , diag_timestamp_created
  , diag_role_created
  , diag_timestamp_modified
  , diag_wallclock_modified
  , diag_role_modified
  , diag_row_version
  , diag_update_count
FROM ms_syst_data.syst_access_account_instance_assocs;

ALTER VIEW ms_syst.syst_access_account_instance_assocs OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_access_account_instance_assocs FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_access_account_instance_assocs
    INSTEAD OF INSERT ON ms_syst.syst_access_account_instance_assocs
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_access_account_instance_assocs();

CREATE TRIGGER a50_trig_i_u_syst_access_account_instance_assocs
    INSTEAD OF UPDATE ON ms_syst.syst_access_account_instance_assocs
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_access_account_instance_assocs();

CREATE TRIGGER a50_trig_i_d_syst_access_account_instance_assocs
    INSTEAD OF DELETE ON ms_syst.syst_access_account_instance_assocs
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_access_account_instance_assocs();

COMMENT ON
    VIEW ms_syst.syst_access_account_instance_assocs IS
$DOC$Associates access accounts with the instances for which they are allowed to
authenticate to.  Note that being able to authenticate to an instance is not the
same as having authorized rights within the instance; authorization is handled
by the instance directly.

This API View allows the application to read and maintain the data according to
well defined application business rules.  Using this API view for updates to
data is the preferred method of data maintenance in the course of normal usage.

Only user maintainable values may be maintained via this API.  System created or
maintained data is not maintainable via this view.  Attempts at invalid data
maintenance via this API may result in the invalid changes being ignored or may
raise an exception.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_account_instance_assocs.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_account_instance_assocs.access_account_id IS
$DOC$The access account which is being granted authentication rights to the given
instance.

This value may only be set on INSERT via this API view.  UPDATEs to this value
are not allowed after record creation.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_account_instance_assocs.instance_id IS
$DOC$The identity of the instance to which authentication rights is being granted.

This value may only be set on INSERT via this API view.  UPDATEs to this value
are not allowed after record creation.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_account_instance_assocs.access_granted IS
$DOC$The timestamp at which access to the instance was granted and active.  If
the access did not require the access invitation process, this value will
typically reflect the creation timestamp of the record.  If the invitation was
required, it will reflect the time when the access account holder actually
accepted the invitation to access the instance.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_account_instance_assocs.invitation_issued IS
$DOC$When inviting unowned, independent access accounts such as might be used by an
external bookkeeper, the grant of access by the instance owner is
not immediately effective but must also be approved by the access account holder
being granted access.  The timestamp in this column indicates when the
invitation to connect to the instance was issued.

If the value in this column is null, the assumption is that no invitation was
required to grant the access to the access account.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_account_instance_assocs.invitation_expires IS
$DOC$The timestamp at which the invitation to access a given instance expires.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_account_instance_assocs.invitation_declined IS
$DOC$The timestamp at which the access account holder explicitly declined the
invitation to access the given instance.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_account_instance_assocs.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_account_instance_assocs.diag_role_created IS
$DOC$The database role which created the record.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_account_instance_assocs.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_account_instance_assocs.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_account_instance_assocs.diag_role_modified IS
$DOC$The database role which modified the record.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_account_instance_assocs.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_account_instance_assocs.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.

This value is read only from this API view.$DOC$;
