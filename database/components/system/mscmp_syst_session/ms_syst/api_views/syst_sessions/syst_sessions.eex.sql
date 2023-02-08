-- File:        syst_sessions.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_session/ms_syst/api_views/syst_sessions/syst_sessions.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE VIEW ms_syst.syst_sessions AS
SELECT
    id
  , internal_name
  , session_data
  , session_expires
  , diag_timestamp_created
  , diag_role_created
  , diag_timestamp_modified
  , diag_wallclock_modified
  , diag_role_modified
  , diag_row_version
  , diag_update_count
FROM ms_syst_data.syst_sessions;

ALTER VIEW ms_syst.syst_sessions OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_sessions FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_sessions
    INSTEAD OF INSERT ON ms_syst.syst_sessions
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_sessions();

CREATE TRIGGER a50_trig_i_u_syst_sessions
    INSTEAD OF UPDATE ON ms_syst.syst_sessions
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_sessions();

CREATE TRIGGER a50_trig_i_d_syst_sessions
    INSTEAD OF DELETE ON ms_syst.syst_sessions
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_sessions();

COMMENT ON
    VIEW ms_syst.syst_sessions IS
$DOC$Database persistence of user interface related session data.

This API View allows the application to read and maintain the data according to
well defined application business rules.  Using this API view for updates to
data is the preferred method of data maintenance in the course of normal usage.

Only user maintainable values may be maintained via this API.  System created or
maintained data is not maintainable via this view.  Attempts at invalid data
maintenance via this API may result in the invalid changes being ignored or may
raise an exception.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_sessions.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_sessions.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.

This value may only be set on INSERT via this API view.  UPDATE operations are
not allowed to this column once the record is created.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_sessions.session_data IS
$DOC$A binary representation of user session data.  The data itself will vary
depending on the specific needs of user interface interactions.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_sessions.session_expires IS
$DOC$A Timestamp indicating the Date/Time at which the session will no longer be
considered valid and will eligible for purging from the system.  Prior to the
expiration time, the session may be renewed and the session_expires time may be
updated to a later time.  After the session_expires timestamp is past, however,
the session may not be updated and a new session will need to be established,
typically via a new user authentication process.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_sessions.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_sessions.diag_role_created IS
$DOC$The database role which created the record.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_sessions.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_sessions.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_sessions.diag_role_modified IS
$DOC$The database role which modified the record.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_sessions.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_sessions.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.

This value is read only from this API view.$DOC$;
