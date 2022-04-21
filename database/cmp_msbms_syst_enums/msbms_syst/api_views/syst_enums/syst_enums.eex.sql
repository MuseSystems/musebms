-- File:        syst_enums.eex.sql
-- Location:    database\cmp_msbms_syst_enums\msbms_syst\api_views\syst_enums\syst_enums.eex.sql
-- Project:     Muse Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE VIEW msbms_syst.syst_enums AS
    SELECT
        id
      , internal_name
      , display_name
      , syst_description
      , user_description
      , syst_defined
      , user_maintainable
      , default_syst_options
      , default_user_options
      , diag_timestamp_created
      , diag_role_created
      , diag_timestamp_modified
      , diag_wallclock_modified
      , diag_role_modified
      , diag_row_version
      , diag_update_count
    FROM msbms_syst_data.syst_enums;

ALTER VIEW msbms_syst.syst_enums OWNER TO <%= msbms_owner %>;

REVOKE ALL ON TABLE msbms_syst.syst_enums FROM PUBLIC;

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE msbms_syst.syst_enums TO <%= msbms_appusr %>;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE msbms_syst.syst_enums TO <%= msbms_apiusr %>;

CREATE TRIGGER a50_trig_i_i_syst_enums
    INSTEAD OF INSERT ON msbms_syst.syst_enums
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst.trig_i_i_syst_enums();

CREATE TRIGGER a50_trig_i_u_syst_enums
    INSTEAD OF UPDATE ON msbms_syst.syst_enums
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst.trig_i_u_syst_enums();

CREATE TRIGGER a50_trig_i_d_syst_enums
    INSTEAD OF DELETE ON msbms_syst.syst_enums
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst.trig_i_d_syst_enums();

COMMENT ON
    VIEW msbms_syst.syst_enums IS
$DOC$Enumerates the enumerations known to the system along with additional metadata
useful in applying them appropriately.

This API View allows the application to read and maintain the data according to
well defined application business rules.  Using this API view for updates to
data is the preferred method of data maintenance in the course of normal usage.

Only user maintainable values may be maintained via this API.  System created or
maintained data is not maintainable via this view.  Attempts at invalid data
maintenance via this API may result in the invalid changes being ignored or may
raise an exception.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_enums.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_enums.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_enums.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_enums.syst_description IS
$DOC$A default description of the enumeration which might include details such as how
the enumeration is used and what kind of functionality might be impacted by
choosing specific enumeration values.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_enums.user_description IS
$DOC$A user defined description of the enumeration to support custom user
documentation of the purpose and function of the enumeration.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_enums.syst_defined IS
$DOC$If true, this value indicates that the enumeration is considered part of the
application.  Often times, system enumerations are manageable by users, but the
existence of the enumeration in the system is assumed to exist by the
application.  If false, the assumption is that the enumeration was created by
users and supports custom user functionality.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_enums.user_maintainable IS
$DOC$When true, this column indicates that the enumeration is user maintainable;
this might include the ability to add, edit, or remove enumeration values.  When
false, the enumeration is strictly system managed for any functional purpose.
Note that the value of this column doesn't effect the ability to set a
user_description value; the ability to set custom descriptions is always
available for any properly authorized user.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_enums.default_syst_options IS
$DOC$Establishes the expected extended system options along with default values if
applicable.  Note that this setting is used to both validate
and set defaults in the syst_enum_items.syst_options column.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_enums.default_user_options IS
$DOC$Allows a user to set the definition of syst_enum_items.user_options values and
provide defaults for those values if appropriate.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_enums.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_enums.diag_role_created IS
$DOC$The database role which created the record.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_enums.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_enums.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_enums.diag_role_modified IS
$DOC$The database role which modified the record.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_enums.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_enums.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.

Note that this column may not be updated via this API View.$DOC$;
