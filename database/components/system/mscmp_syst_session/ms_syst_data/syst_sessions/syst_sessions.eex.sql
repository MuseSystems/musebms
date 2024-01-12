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

DO
$DOCUMENTATION$
DECLARE
    -- Table
    var_comments_config ms_syst_priv.comments_config_table;

    -- Columns
    var_session_data    ms_syst_priv.comments_config_table_column;
    var_session_expires ms_syst_priv.comments_config_table_column;

BEGIN

    --
    -- Table Config
    --

    var_comments_config.table_schema := 'ms_syst_data';
    var_comments_config.table_name   := 'syst_sessions';

    var_comments_config.description :=
$DOC$Database persistence of user interface related session data.$DOC$;

    --
    -- Column Configs
    --

    var_session_data.column_name := 'session_data';
    var_session_data.description :=
$DOC$A binary representation of user session data.  The data itself will vary
depending on the specific needs of user interface interactions.$DOC$;

    var_session_expires.column_name := 'session_expires';
    var_session_expires.description :=
$DOC$A Timestamp indicating the Date/Time at which the session will no longer be
considered valid and will eligible for purging from the system.$DOC$;
    var_session_expires.general_usage :=
$DOC$Prior to the expiration time, the session may be renewed and the session_expires
time may be updated to a later time.  After the session_expires timestamp is
past, however, the session may not be updated and a new session will need to be
established, typically via a new user authentication process.$DOC$;

    var_comments_config.columns :=
        ARRAY [
              var_session_data
            , var_session_expires
            ]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( var_comments_config );

END;
$DOCUMENTATION$;
