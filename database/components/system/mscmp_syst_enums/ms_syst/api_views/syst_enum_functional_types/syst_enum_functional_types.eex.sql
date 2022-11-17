-- File:        syst_enum_functional_types.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_enums/ms_syst/api_views/syst_enum_functional_types/syst_enum_functional_types.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE VIEW ms_syst.syst_enum_functional_types AS
    SELECT
        seft.id
      , seft.internal_name
      , seft.display_name
      , seft.external_name
      , se.syst_defined
      , seft.enum_id
      , seft.syst_description
      , seft.user_description
      , seft.diag_timestamp_created
      , seft.diag_role_created
      , seft.diag_timestamp_modified
      , seft.diag_wallclock_modified
      , seft.diag_role_modified
      , seft.diag_row_version
      , seft.diag_update_count
    FROM ms_syst_data.syst_enum_functional_types seft
        JOIN ms_syst_data.syst_enums se
            ON se.id = seft.enum_id;

ALTER VIEW ms_syst.syst_enum_functional_types OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_enum_functional_types FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_enum_functional_types
    INSTEAD OF INSERT ON ms_syst.syst_enum_functional_types
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_enum_functional_types();

CREATE TRIGGER a50_trig_i_u_syst_enum_functional_types
    INSTEAD OF UPDATE ON ms_syst.syst_enum_functional_types
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_enum_functional_types();

CREATE TRIGGER a50_trig_i_d_syst_enum_functional_types
    INSTEAD OF DELETE ON ms_syst.syst_enum_functional_types
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_enum_functional_types();

COMMENT ON
    VIEW ms_syst.syst_enum_functional_types IS
$DOC$For those enumerations requiring functional type designation, this table defines
the available types and persists related metadata.  Note that not all
enumerations require functional types.

This API View allows the application to read and maintain the data according to
well defined application business rules.  Using this API view for updates to
data is the preferred method of data maintenance in the course of normal usage.

Only user maintainable values may be maintained via this API.  System created or
maintained data is not maintainable via this view.  Attempts at invalid data
maintenance via this API may result in the invalid changes being ignored or may
raise an exception.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_functional_types.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_functional_types.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_functional_types.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_functional_types.external_name IS
$DOC$A non-unique/non-key value used to display to users and external parties where
uniqueness is less of a concern than specific end user presentation.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_functional_types.syst_defined IS
$DOC$If true, this value indicates that the functional type is considered to be
system defined and a part of the application.  This column is not part of the
functional type underlying data and is a reflect of the functional type's parent
enumeration since the parent determines if the functional type is considered
system defined.  If false, the assumption is that the functional type is user
defined and supports custom user functionality.

See the documentation for ms_syst.syst_enums.syst_defined for a more complete
complete description.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_functional_types.enum_id IS
$DOC$A reference to the owning enumeration of the functional type.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_functional_types.syst_description IS
$DOC$A default description of the specific functional type and its use cases within
the enumeration which is identitied as the parent.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_functional_types.user_description IS
$DOC$A custom, user suppplied description of the functional type which will be
preferred over the syst_description field if set to a not null value.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_functional_types.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_functional_types.diag_role_created IS
$DOC$The database role which created the record.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_functional_types.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_functional_types.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_functional_types.diag_role_modified IS
$DOC$The database role which modified the record.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_functional_types.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_functional_types.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.

Note that this column may not be updated via this API View.$DOC$;
