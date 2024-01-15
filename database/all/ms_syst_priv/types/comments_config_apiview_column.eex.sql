-- File:        comments_config_apiview_column.eex.sql
-- Location:    musebms/database/all/ms_syst_priv/types/comments_config_apiview_column.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TYPE ms_syst_priv.comments_config_apiview_column AS
(
      column_name          text
    , required             boolean
    , unique_values        boolean
    , default_value        text
    , override_description text
    , supplemental         text
    , user_insert          boolean
    , user_select          boolean
    , user_update          boolean
    , syst_select          boolean
    , syst_update_mode     ms_syst_priv.comments_apiview_update_modes
);

COMMENT ON TYPE ms_syst_priv.comments_config_apiview_column IS
$DOC$Provides a standardized data structure for defining API View column
documentation.

Values of this type are typically used with the
`ms_syst_priv.generate_comments_apiview` function.  Column comments for this
type assume usage with that function when describing values, constraints, and
other behaviors.
$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_apiview_column.column_name IS
$DOC$A string value which identifies the column of the API View which is the target
of the comment.  This value is required.
$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_apiview_column.required IS
$DOC$A boolean value which indicates if the API View considers a value in this column
required.  This will often times equate to the underlying Data Table column
being constrained as `NOT NULL`
$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_apiview_column.unique_values IS
$DOC$A boolean value which indicates if the API View and underlying data require
that any submitted values are unique in the database.  If `TRUE`, the
expectation is that all values presented are unique and any duplicated values
will result in an exception.  If `FALSE` then duplicated values are expected to
be accepted by the API View.
$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_apiview_column.default_value IS
$DOC$A string value containing the default value which is set by the API View if no
other value for the column is provided.  Note that this value isn't necessarily
the default defined by an underlying Data Table as the API Views may establish
their own default or not make use of Data Table defaults.  This value is optional
if it is null or not provided a simple text explaining that no default is
defined is included in the comments.
$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_apiview_column.override_description IS
$DOC$A string field which will override any text which might originate from an
identified base Data Table column.  If there is no identified base Data Table
column from which to draw a description, this value will be the only way to
provide a primary descriptive text for the API View column.  This value is not
required and not providing it will allow the base Data Table's description to be
used, or a message indicating that the API View is not documented if no
descriptive text is resolvable.
$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_apiview_column.supplemental IS
$DOC$A string value which allows supplemental notes to be provided in addition to the
API View column description.  If the value is not `NULL`, a special
"Supplemental" section will be added for the text. This value is optional and if
the not provided a "Supplemental" section will not be present.
$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_apiview_column.user_insert IS
$DOC$A boolean value indicating if the API View column may be used when inserting
user defined data.  This value is not required and will default to a value of
`TRUE` if not otherwise provided.
$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_apiview_column.user_select IS
$DOC$A boolean value indicating if the API View column may be used when selecting
user defined data.  This value is not required and will default to a value of
`TRUE` if not otherwise provided.$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_apiview_column.user_update IS
$DOC$A boolean value indicating if the API View column may be used when updating user
defined data.  This value is not required and will default to a value of `TRUE` if
not otherwise provided.
$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_apiview_column.syst_update_mode IS
$DOC$A string value which establishes the specific rule for updates when the target
data is "System Defined" data and such data is updatable as established at the
API View level.  The value is optional, but if set it must be of a value
available from the `ms_syst_priv.comments_apiview_update_modes` database enum
type.  The valid values are:

  * `always` - indicates that the column is always updatable for system defined
    data, even if the data is not marked "user maintainable".

  * `maint` - indicates that the column is only updatable if the system defined
    data is marked as user maintainable.

  * `never` - indicates that the column is not updatable under any circumstances
    when the data is system defined.
$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_apiview_column.syst_select IS
$DOC$A boolean value which indicates if the API View column provides data when used
to query data considered system defined.  This value is optional and defaults to
a value of `TRUE` when not provided.
$DOC$;
