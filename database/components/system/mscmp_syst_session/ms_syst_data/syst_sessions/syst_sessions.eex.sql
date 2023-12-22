-- File:        syst_sessions.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_session/ms_syst_data/syst_sessions/syst_sessions.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TABLE ms_syst_data.syst_sessions
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v7( )
        CONSTRAINT syst_sessions_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_sessions_internal_name_udx UNIQUE
    ,session_data
        jsonb
    ,session_expires
        timestamptz
        NOT NULL
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
) WITH (fillfactor = 90);

ALTER TABLE ms_syst_data.syst_sessions OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_sessions FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_sessions TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_sessions
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE ms_syst_data.syst_sessions IS
$DOC$Database persistence of user interface related session data.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_sessions.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_sessions.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_sessions.session_data IS
$DOC$A binary representation of user session data.  The data itself will vary
depending on the specific needs of user interface interactions.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_sessions.session_expires IS
$DOC$A Timestamp indicating the Date/Time at which the session will no longer be
considered valid and will eligible for purging from the system.  Prior to the
expiration time, the session may be renewed and the session_expires time may be
updated to a later time.  After the session_expires timestamp is past, however,
the session may not be updated and a new session will need to be established,
typically via a new user authentication process.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_sessions.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_sessions.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_sessions.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_sessions.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_sessions.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_sessions.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_sessions.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
