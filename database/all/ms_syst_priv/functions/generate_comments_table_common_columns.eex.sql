CREATE OR REPLACE FUNCTION
    ms_syst_priv.generate_comments_table_common_columns(
        p_table_schema text,
        p_table_name   text)
RETURNS void AS
$BODY$

-- File:        generate_comments_table_common_columns.eex.sql
-- Location:    musebms/database/all/ms_syst_priv/functions/generate_comments_table_common_columns.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

DECLARE
    var_table regclass := ( p_table_schema || '.' || p_table_name )::regclass;

    var_common_col_names text[] :=
        ARRAY [
              'id'
            , 'internal_name'
            , 'display_name'
            , 'external_name'
            , 'syst_defined'
            , 'user_maintainable'
            , 'syst_description'
            , 'user_description'
            , 'diag_timestamp_created'
            , 'diag_role_created'
            , 'diag_timestamp_modified'
            , 'diag_wallclock_modified'
            , 'diag_role_modified'
            , 'diag_row_version'
            , 'diag_update_count']::text[];

    var_id text :=
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

    var_internal_name text :=
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

    var_display_name text :=
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions$DOC$;

    var_external_name text :=
$DOC$A non-unique/non-key value used to display to users and external parties where
uniqueness is less of a concern than specific end user presentation.$DOC$;

    var_syst_defined text :=
$DOC$Values of `TRUE` in this column indicate that the record is considered a
"System Defined" record, a record which is created and primarily maintained by
the system using automated processes.  A value of `FALSE` indicates that the
record is considered a "User Defined" record which is maintained by user actions
in the application.$DOC$;

    var_user_maintainable text :=
$DOC$If a record is system defined (see the `syst_defined` column`), there may be
some user data maintenance operations permitted in some cases.  If the value of
this column for a record is `TRUE` and the record is also "System Defined", then
permitted user maintenance operations are available for the record.  If the
record is system defined and the value of this column is `FALSE`, no user
maintenance is allowed.  If the record is not system defined, the value in this
column will have no meaning or effect; user defined records may set this value
`TRUE` as a simple information point indicating that the record is user
maintainable.$DOC$;

    var_syst_description text :=
$DOC$A system defined description indicating the purpose and use cases of a given
record.  Text defined in this column is system maintained and should not be
changed under normal circumstances.$DOC$;

    var_user_description text :=
$DOC$An optional user defined description of the record and its use cases.  If this
value is not `NULL`, the value will override any `syst_description` defined text
in application user interfaces and other presentations.$DOC$;

    var_diag_timestamp_created text :=
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

    var_diag_role_created text :=
$DOC$The database role which created the record.$DOC$;

    var_diag_timestamp_modified text :=
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

    var_diag_wallclock_modified text :=
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

    var_diag_role_modified text :=
$DOC$The database role which modified the record.$DOC$;

    var_diag_row_version text :=
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

    var_diag_update_count text :=
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;

BEGIN

    PERFORM
        ms_syst_priv.generate_comments_table_column(
            p_table_schema => p_table_schema,
            p_table_name => p_table_name,
            p_comments_config =>
                (
                --column_name
                  pa.attname
                --description
                , CASE
                    WHEN pa.attname = 'id' THEN
                        var_id
                    WHEN pa.attname = 'internal_name' THEN
                        var_internal_name
                    WHEN pa.attname = 'display_name' THEN
                        var_display_name
                    WHEN pa.attname = 'external_name' THEN
                        var_external_name
                    WHEN pa.attname = 'syst_defined' THEN
                        var_syst_defined
                    WHEN pa.attname = 'user_maintainable' THEN
                        var_user_maintainable
                    WHEN pa.attname = 'syst_description' THEN
                        var_syst_description
                    WHEN pa.attname = 'user_description' THEN
                        var_user_description
                    WHEN pa.attname = 'diag_timestamp_created' THEN
                        var_diag_timestamp_created
                    WHEN pa.attname = 'diag_role_created' THEN
                        var_diag_role_created
                    WHEN pa.attname = 'diag_timestamp_modified' THEN
                        var_diag_timestamp_modified
                    WHEN pa.attname = 'diag_wallclock_modified' THEN
                        var_diag_wallclock_modified
                    WHEN pa.attname = 'diag_role_modified' THEN
                        var_diag_role_modified
                    WHEN pa.attname = 'diag_row_version' THEN
                        var_diag_row_version
                    WHEN pa.attname = 'diag_update_count' THEN
                        var_diag_update_count
                    ELSE
                        NULL::text
                  END
                --general_usage
                , CASE
                    WHEN pa.attname IN ('external_name', 'user_description') THEN
                        NULL
                    ELSE
                        E'This column is system maintained and should be ' ||
                        E'considered read only in normal\noperations.'
                  END
                --func_type_name
                , NULL::text
                --func_type_text
                , NULL::text
                --state_name
                , NULL::text
                --state_text
                , NULL::text
                --constraints
                , NULL::text
                --direct_usage
                , CASE
                    WHEN pa.attname = 'diag_row_version' THEN
                        E'This column is frequently used by by application ' ||
                        E'logic to resolve the "dirty\nwrite" issues which ' ||
                        E'can arise from concurrent data changes.  As such ' ||
                        E'any\nadministrative override of automatic system ' ||
                        E'maintenance of this value should\nconsider the ' ||
                        E'ramifications on application function.'
                    ELSE
                        NULL::text
                  END)::ms_syst_priv.comments_config_table_column
        )
    FROM pg_attribute pa
    WHERE
          pa.attrelid = var_table
      AND pa.attnum > 0
      AND pa.attname::text = ANY (var_common_col_names)
      AND NOT pa.attisdropped;

END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION
    ms_syst_priv.generate_comments_table_common_columns(
        p_table_schema text,
        p_table_name   text)
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION
    ms_syst_priv.generate_comments_table_common_columns(
        p_table_schema text,
        p_table_name   text)
    FROM public;

GRANT EXECUTE ON FUNCTION
    ms_syst_priv.generate_comments_table_common_columns(
        p_table_schema text,
        p_table_name   text)
    TO <%= ms_owner %>;

COMMENT ON FUNCTION
    ms_syst_priv.generate_comments_table_common_columns(
        p_table_schema text,
        p_table_name   text)
    IS
$DOC$#### Private Function `ms_syst_priv.generate_comments_table_common_columns`

Provides boilerplate column comment configurations for columns which are common
to many columns and applies these comment configurations to any table columns
which are found to be in the set of common columns.

Note that if there are customizations or overrides desired when documenting
these common columns for a given table, such overrides should appear in the
columns list passed to `ms_syst_priv.generate_comments_table`, directly by
calling `ms_syst_priv.generate_comments_table_column`, or by simply commenting
on the desired column directly.$DOC$;
