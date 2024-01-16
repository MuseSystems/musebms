-- File:        comments_config_table.eex.sql
-- Location:    musebms/database/all/ms_syst_priv/types/comments_config_table.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TYPE ms_syst_priv.comments_config_table AS
(
      table_schema    text
    , table_name      text
    , description     text
    , general_usage   text
    , constraints     text
    , direct_usage    text
    , generate_common boolean
    , columns         ms_syst_priv.comments_config_table_column[]
);

COMMENT ON TYPE ms_syst_priv.comments_config_table IS
$DOC$Provides a standardized data structure for defining table documentation.

**General Usage**

Values of this type are typically used with the
`ms_syst_priv.generate_commons_table` function.  Column comments for this type
assume usage with that function when describing values, constraints, and other
behaviors.
$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_table.table_schema IS
$DOC$The name of the database schema to which the target table belongs.  This field
is required.
$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_table.table_name IS
$DOC$The name of the database table for which the comments will will be created.
This field is required.
$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_table.description IS
$DOC$The text which describes the purpose and use cases of the table.  If this
value is `NULL`, a default text indicating no documentation will be defaulted.
$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_table.general_usage IS
$DOC$Optional general directions for usage of the table which apply in all cases,
including if the table is accessed via and API layer. If a text is provided
using this value, a "General Usage" section will be added to the table comment;
if this value is null then the section will not appear.
$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_table.constraints IS
$DOC$Optional notes describing how to handle imposed constraints or validations
related to the data.  This text is primarily to support cases where the code or
documentation associated directly with the defined constraints or triggers are
not sufficient for understanding the goals or special handling required.  If
this value is not null, a "Constraints" section will be added to the table
comment; if this value is `NULL` then the section will not appear.
$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_table.direct_usage IS
$DOC$Optional directions for usage of the table which only apply when not accessing
the table through an API or other mediating layer which may apply additional
validations or data safety measures.  If a text is provided using the value, a
"Direct Usage" section will be added to the table comment; if this value is null
then the section will not appear.
$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_table.generate_common IS
$DOC$An optional boolean value which indicates if table comment generation should
also automatically generate comments for those common columns which accompany
most tables.

A value of `TRUE` will attempt to generate the column comments for any of the
common columns defined for the table; if `FALSE` then automatic common column
comment generation will be skipped.  In all cases, manual inclusion of common
column comments in the `columns` field will override any automatic comment
generation for that column.  The default value is `TRUE` if not otherwise
provided.

See the `ms_syst_priv.generate_comments_table_common_columns` function for more
including which common columns are processed.
$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_table.columns IS
$DOC$An optional array of `ms_syst_priv.comments_config_table_column` objects for
generating comments on the table's columns.  Please see the documentation for
the `ms_syst_priv.comments_config_table_column` type for the more information
concerning configuring comments for table columns.
$DOC$;
