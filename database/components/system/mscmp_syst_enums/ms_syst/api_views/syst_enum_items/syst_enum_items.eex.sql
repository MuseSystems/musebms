-- File:        syst_enum_items.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_enums/ms_syst/api_views/syst_enum_items/syst_enum_items.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE VIEW ms_syst.syst_enum_items AS
    SELECT
        id
      , internal_name
      , display_name
      , external_name
      , enum_id
      , functional_type_id
      , enum_default
      , functional_type_default
      , syst_defined
      , user_maintainable
      , syst_description
      , user_description
      , sort_order
      , syst_options
      , user_options
      , diag_timestamp_created
      , diag_role_created
      , diag_timestamp_modified
      , diag_wallclock_modified
      , diag_role_modified
      , diag_row_version
      , diag_update_count
    FROM ms_syst_data.syst_enum_items;

ALTER VIEW ms_syst.syst_enum_items OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_enum_items FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_enum_items
    INSTEAD OF INSERT ON ms_syst.syst_enum_items
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_enum_items();

CREATE TRIGGER a50_trig_i_u_syst_enum_items
    INSTEAD OF UPDATE ON ms_syst.syst_enum_items
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_enum_items();

CREATE TRIGGER a50_trig_i_d_syst_enum_items
    INSTEAD OF DELETE ON ms_syst.syst_enum_items
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_enum_items();

COMMENT ON
    VIEW ms_syst.syst_enum_items IS
$DOC$The list of values provided by an enumeration as well as related behavioral and
informational metadata.

This API View allows the application to read and maintain the data according to
well defined application business rules.  Using this API view for updates to
data is the preferred method of data maintenance in the course of normal usage.

Only user maintainable values may be maintained via this API.  System created or
maintained data is not maintainable via this view.  Attempts at invalid data
maintenance via this API may result in the invalid changes being ignored or may
raise an exception.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_items.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_items.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_items.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_items.external_name IS
$DOC$A non-unique/non-key value used to display to users and external parties where
uniqueness is less of a concern than specific end user presentation.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_items.enum_id IS
$DOC$The enumeration record with which the value is associated.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_items.functional_type_id IS
$DOC$If the enumeration requires a functional type, this column references the
functional type associated with the enumeration value record.  Note that not all
enumerations require functional types.  If syst_enum_functional_types records
exist for an enumeration, then this column will be required for any values of
that enumeration; if there are no functional types defined for an enumeration,
the this column must remain NULL.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_items.enum_default IS
$DOC$If true, indicates that this value is the default selection from all values
defined for the enumerations.  If false then the value record has no special
significance relative to defaulting.

Note that if a record is inserted or updated in this table with enum_default set
true, and another record already exists for the enumeration with its
enum_default set true, the newly inserted/updated record will take precedence
and the value record previously set to be default will have its enum_default
setting set to false.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_items.functional_type_default IS
$DOC$If true, the value record is the default selection for any of a specific
fucntional type.  This is helpful in situations where a progression of state is
automatically processed by the system and the state is represented by an
enumeration.  In cases where there are no functional types, this value should
simply remain false.

Note that if a record is inserted or updated in this table with its
functional_type_default set true, and another record already exists for the
enumeration/functional type combination with its functional_type_default set
true, the newly inserted/updated record will take precedence and the value
record previously set to be default will have its functional_type_default
setting set to false.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_items.syst_defined IS
$DOC$If true, indicates that the value was created by the system or system
installation process.  A false value indicates that the record was user created.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_items.user_maintainable IS
$DOC$If true, the user may maintain the value including setting user_options or
even setting the record inactive/deleting it.  If false, the value record is
required by the system for correct operation.  The user_description and
user_options columns are always available for user maintenance regardless of
this setting.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_items.syst_description IS
$DOC$A system default description describing the value and its use cases within the
enumeration.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_items.user_description IS
$DOC$A custom user defined description which overrides the syst_description value
where it would otherwise be used.  If this column is set NULL the
syst_description value will be used.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_items.sort_order IS
$DOC$Indicates the sort ordering of the particular value record with the lowest value
sorting first.  When a value record for an enumeration is inserted or updated
and this column is being set to a value which equals another enumeration value
record for the same enumeration, the system assumes that the new record is
being set to precede the existing record and it will be set to sort after the
newly inserted/updated enumeration value.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_items.syst_options IS
$DOC$Extended options and metadata which describe the behavior and meaning of the
specific value within the enumeration.  The owning
syst_enums record's default_syst_options column will indicate what syst_options
are required or available and establishes default values for them.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_items.user_options IS
$DOC$Extended user defined options, similar to syst_options, but for the purpose of
driving custom functionality.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_items.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_items.diag_role_created IS
$DOC$The database role which created the record.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_items.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_items.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_items.diag_role_modified IS
$DOC$The database role which modified the record.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_items.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_items.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.

Note that this column may not be updated via this API View.$DOC$;