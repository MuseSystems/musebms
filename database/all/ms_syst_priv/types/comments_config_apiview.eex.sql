-- File:        comments_config_apiview.eex.sql
-- Location:    musebms/database/all/ms_syst_priv/types/comments_config_apiview.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TYPE ms_syst_priv.comments_config_apiview AS
(
      table_schema         text
    , table_name           text
    , view_schema          text
    , view_name            text
    , override_description text
    , supplemental         text
    , user_records         boolean
    , user_record_insert   boolean
    , user_record_select   boolean
    , user_record_update   boolean
    , user_record_delete   boolean
    , syst_records         boolean
    , syst_record_select   boolean
    , syst_record_update   boolean
    , syst_record_delete   boolean
    , generate_common      boolean
    , columns              ms_syst_priv.comments_config_apiview_column[]
);

COMMENT ON TYPE ms_syst_priv.comments_config_apiview IS
$DOC$#### Private Type `ms_syst_priv.comments_config_apiview`

Provides a standardized data structure for defining API View column
documentation.

Values of this type are typically used with the
`ms_syst_priv.generate_comments_apiview` function.  Column comments for this
type assume usage with that function when describing values, constraints, and
other behaviors.
$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_apiview.table_schema IS
$DOC$If the API View is closely related to a base Data table, the name of the
database schema which contains that table should be named here.  If this value
is null, then no attempt will be made to extract Data Table related comments; in
such cases the `override_description` texts of both the API View and its columns
will need to be provided for any comments to be added.  This value is optional
and defaults to null.
$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_apiview.table_name IS
$DOC$This is the table name of the Data Table which is contained in the identified
`table_schema`, described above.  This value is optional and defaults to `NULL`.
$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_apiview.view_schema IS
$DOC$The name of the database schema which contains the API View for which comments
are being generated.  This value is required.
$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_apiview.view_name IS
$DOC$The name of the API View which is contained in the identified `view_schema`
value discussed above.  This value is required.
$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_apiview.override_description IS
$DOC$A string field which will override any text which might originate from an
identified base Data Table (see values `table_schema` and `table_name`).  If
there is no identified base Data Table, this value will be the only way to
provide a primary descriptive text for the API View.  This value is not required
and not providing it will allow the base Data Table's description to be used, or
a message indicating that the API View is not documented if no descriptive text
is resolvable.
$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_apiview.supplemental IS
$DOC$A string value which allows supplemental notes to be provided in addition to the
API View description.  If the value is not `NULL`, a special "Supplemental"
section will be added for the text. This value is optional and if the value is
missing or of a `NULL` value the "Supplemental" section will not be present.
$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_apiview.user_records IS
$DOC$A boolean value which indicates if the API View will process user defined data.
User defined data is data which is created and managed by end users in the
normal course of performing business operations.  This value is optional and
defaults to `TRUE` if not provided.
$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_apiview.user_record_insert IS
$DOC$A boolean value which indicates if the API View allows for `INSERT` operations
to create new user defined data.  This value is not required and defaults to
`TRUE` if not provided.
$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_apiview.user_record_select IS
$DOC$A boolean value which indicates if the API View may be used to read existing
user defined data.  This value is not required and defaults to `TRUE` if not
provided.
$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_apiview.user_record_update IS
$DOC$A boolean value which indicates if the API View may be used to update existing
user defined data.  This value is not required and defaults to `TRUE` if not
provided.
$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_apiview.user_record_delete IS
$DOC$A boolean value which indicates if the API View may be used to delete existing
user defined data.  This value is not required and defaults to `TRUE` if not
provided.
$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_apiview.syst_records IS
$DOC$A boolean value which indicates if the API View will process system defined
data.  System defined data is data which is automatically created and maintained
by the system or is created by the application developers and typically does not
support or restricts user maintenance activities.  This value is not required
and defaults to `FALSE` if not provided.
$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_apiview.syst_record_select IS
$DOC$A boolean value which indicates if the API View may be used to read existing
system defined data.  This value is not required and defaults to `TRUE` if not
provided.
$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_apiview.syst_record_update IS
$DOC$A boolean value which indicates if the API View may be used to update system
defined data.  Typically each column of a system defined record will specify if
it is updatable and under what conditions.  This value is not required and
defaults to `FALSE` if not provided.
$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_apiview.syst_record_delete IS
$DOC$A boolean value which indicates if the API View may be used to delete system
defined data.  Typically this would be system defined child data or records of
some system defined master relation.  This value is not required and defaults to
`FALSE` if not provided.
$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_apiview.generate_common IS
$DOC$Indicates that the API View comment generation should also attempt to
automatically create API View column comments for columns which commonly
accompany most Data Tables.

If `TRUE` the attempt will be made each for common column.  If `FALSE` or if the
API View is not based on a Data Table (the `table_schema` or `table_name` fields
are `NULL`), then no attempt will be made.  Note that any common columns that
are also manually specified in the `columns` list field will override any
automatically generated comments.  The default value of this field is `TRUE` if
a base Data Table is identified, `FALSE` otherwise.
$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_apiview.columns IS
$DOC$An array of `ms_syst_priv.comments_config_apiview_column` objects providing the
comment configurations for the API View columns.  This value is not required,
though is typically defined.  Please see the database type comments for
`ms_syst_priv.comments_config_apiview_column` for more information.
$DOC$;
