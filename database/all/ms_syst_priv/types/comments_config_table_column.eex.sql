-- File:        comments_config_table_column.eex.sql
-- Location:    musebms/database/all/ms_syst_priv/types/comments_config_table_column.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TYPE ms_syst_priv.comments_config_table_column AS
(
      column_name      text
    , description      text
    , general_usage    text
    , func_type_name   text
    , func_type_text   text
    , state_name       text
    , state_text       text
    , constraints      text
    , direct_usage     text
);

COMMENT ON TYPE ms_syst_priv.comments_config_table_column IS
$DOC$Provides a standardized data structure for defining table column documentation.

**General Usage**

Values of this type are typically used with the
`ms_syst_priv.generate_comments_table_column` function.  Column comments for
this type assume usage with that function when describing values, constraints,
and other behaviors.
$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_table_column.column_name IS
$DOC$the name of the database column to which the comment will apply.  This field is
required.
$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_table_column.description IS
$DOC$the text which describes the purpose and use cases of the column.
$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_table_column.general_usage IS
$DOC$Optional general directions for usage of the column which apply in all cases,
including if the column is accessed via and API layer. If a text is provided
using this value, a "General Usage" section will be added to the column comment;
if this value is null then the section will not appear.
$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_table_column.func_type_name IS
$DOC$if records of the relation require a functional type designation to be
established, this parameter may reference the `internal_name` value of the
Enumeration establishing the available values. This will cause a "Functional
Types" section to be added to the column's comment.  Alternatively, the
`func_type_text` value may be provided.
$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_table_column.func_type_text IS
$DOC$in cases where a boilerplate reference to the functional type Enumeration
doesn't provide sufficient documentation, this value may be provided instead and
allows for providing the full text of the comment in a "Functional Type" section
of the column's comment.
$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_table_column.state_name IS
$DOC$for columns that define a current stage in a record's life-cycle state, setting
this value to the `internal_name` value of the created Enumeration defining the
available states will cause a "State" section to be added to the column's
comments.
$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_table_column.state_text IS
$DOC$if boilerplate text referencing the defining Enumeration is insufficient for
documenting the "State" options of the column, a full alternative text for the
"State" section may be provided using this value.
$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_table_column.constraints IS
$DOC$if the column must comply with imposed constraints or validations, and the code
itself isn't sufficient for understanding the goal of the constraint, a text may
be provided using this value.  When this value is not null a "Constraints"
section will be added to the column comment using the text defined here.
$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_table_column.direct_usage IS
$DOC$Optional directions for usage of the column which only apply when not accessing
the column through an API or other mediating layer which may apply additional
validations or data safety measures.  If a text is provided using the value, a
"Direct Usage" section will be added to the column comment; if this value is
'NULL' then the section will not appear.
$DOC$;
