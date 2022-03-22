-- File:        syst_modules.eex.sql
-- Location:    database\common\msbms_syst_data\tables\syst_modules.eex.sql
-- Project:     Muse Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE msbms_syst_data.syst_modules
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_modules_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_modules_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT syst_modules_display_name_udx UNIQUE
    ,short_display_name
        text
        NOT NULL
        CONSTRAINT syst_modules_short_display_name_udx UNIQUE
    ,syst_description
        text
        NOT NULL
    ,user_description
        text
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
        NOT NULL
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
        NOT NULL
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
);

ALTER TABLE msbms_syst_data.syst_modules OWNER TO <%= msbms_owner %>;

REVOKE ALL ON TABLE msbms_syst_data.syst_modules FROM public;
GRANT ALL ON TABLE msbms_syst_data.syst_modules TO <%= msbms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON msbms_syst_data.syst_modules
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE msbms_syst_data.syst_modules IS
$DOC$Categorizes broad areas of the application's functionality.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_modules.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_modules.internal_name IS
$DOC$A candidate key useful for programatic references to individual records.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_modules.display_name IS
$DOC$A friendly name and candidate key for the record suitable for use in user
interfaces.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_modules.short_display_name IS
$DOC$A friendly name that can be used when a truncated version of the display name
is appropriate.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_modules.syst_description IS
$DOC$A text describing the meaning and use of the specific record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_modules.user_description IS
$DOC$A user customizable description of the module which overrides the
syst_description value where it might otherwise be displayed.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_modules.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_modules.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_modules.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_modules.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_modules.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_modules.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_modules.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
