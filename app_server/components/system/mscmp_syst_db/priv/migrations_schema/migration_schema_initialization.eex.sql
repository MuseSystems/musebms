-- File:        migration_schema_initialization.eex.sql
-- Location:    msbms/priv/migrations_schema/migration_schema_initialization.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

DO
$INIT_DATASTORE$
    BEGIN
        CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
        CREATE EXTENSION IF NOT EXISTS pgcrypto;

        -- Temporary UUIDv7 extension
        --
        -- !!!!! Do not release to production !!!!!
        --
        -- TODO: Remove from code at PostgreSQL 17 release.  PostgreSQL 17 is
        --       expected to have UUIDv7 support.

        IF
            exists( SELECT TRUE
                    FROM pg_available_extensions
                    WHERE name = 'pg_uuidv7' )
        THEN
            CREATE EXTENSION IF NOT EXISTS pg_uuidv7;
        ELSE
            CREATE OR REPLACE FUNCTION public.uuid_generate_v7( )
                RETURNS uuid AS
            $BODY$ SELECT PUBLIC.uuid_generate_v1mc();
                $BODY$
                LANGUAGE sql;
        END IF;

        CREATE SCHEMA IF NOT EXISTS <%= migrations_schema %>
        AUTHORIZATION <%= ms_owner %>;

        COMMENT ON SCHEMA <%= migrations_schema %> IS
$DOC$Datastore migrations management schema.

**All member objects of this schema are considered "private".**

Direct usage of this schema or its member objects is not supported.$DOC$;

        REVOKE USAGE ON SCHEMA <%= migrations_schema %> FROM PUBLIC;

        --
        -- Returns exception details based on the passed parameters represented as a pretty-printed JSON
        -- object.  The returned value is intended to standardize the details related to RAISEd exceptions
        -- and be suitable for use in setting the RAISE DETAILS variable.
        --

        CREATE OR REPLACE FUNCTION
            <%= migrations_schema %>.get_exception_details(p_proc_schema    text
                                                ,p_proc_name      text
                                                ,p_exception_name text
                                                ,p_errcode        text
                                                ,p_param_data     jsonb
                                                ,p_context_data   jsonb)
        RETURNS text AS
        $BODY$

        -- File:        migration_schema_initialization.eex.sql
        -- Location:    msbms/priv/migrations_schema/migration_schema_initialization.eex.sql
        -- Project:     Muse Systems Business Management System
        --
        -- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
        -- This file may include content copyrighted and licensed from third parties.
        --
        -- See the LICENSE file in the project root for license terms and conditions.
        -- See the NOTICE file in the project root for copyright ownership information.
        --
        -- muse.information@musesystems.com  :: https://muse.systems


            SELECT
                jsonb_pretty(
                    jsonb_build_object(
                         'procedure_schema',      p_proc_schema
                        ,'procedure_name',        p_proc_name
                        ,'exception_name',        p_exception_name
                        ,'sqlstate',              p_errcode
                        ,'parameters',            p_param_data
                        ,'context',               p_context_data
                        ,'transaction_timestamp', now()
                        ,'wallclock_timestamp',   clock_timestamp()));

        $BODY$
        LANGUAGE sql VOLATILE;

        ALTER FUNCTION <%= migrations_schema %>.get_exception_details(p_proc_schema    text
                                                            ,p_proc_name      text
                                                            ,p_exception_name text
                                                            ,p_errcode        text
                                                            ,p_param_data     jsonb
                                                            ,p_context_data   jsonb)
            OWNER TO <%= ms_owner %>;

        REVOKE EXECUTE ON FUNCTION
            <%= migrations_schema %>.get_exception_details(p_proc_schema    text
                                                ,p_proc_name      text
                                                ,p_exception_name text
                                                ,p_errcode        text
                                                ,p_param_data     jsonb
                                                ,p_context_data   jsonb)
            FROM public;

        GRANT EXECUTE ON FUNCTION
            <%= migrations_schema %>.get_exception_details( p_proc_schema    text
                                                ,p_proc_name      text
                                                ,p_exception_name text
                                                ,p_errcode        text
                                                ,p_param_data     jsonb
                                                ,p_context_data   jsonb)
            TO <%= ms_owner %>;


        COMMENT ON FUNCTION
            <%= migrations_schema %>.get_exception_details(p_proc_schema    text
                                                ,p_proc_name      text
                                                ,p_exception_name text
                                                ,p_errcode        text
                                                ,p_param_data     jsonb
                                                ,p_context_data   jsonb) IS
$DOC$Returns exception details based on the passed parameters represented as a
pretty-printed JSON object.  The returned value is intended to standardize the
details related to `RAISE`d exceptions and be suitable for use in setting the
`RAISE DETAILS` variable.

**Parameters**

  * **`p_proc_schema`** ::     **Required?** True; **Default**: ( No Default )

    The schema name hosting the function or store procedure which raised the
    exception.

  * **`p_proc_name`** ::     **Required?** True; **Default**: ( No Default )

    The name of the process which raised the exception.

  * **`p_exception_name`** ::     **Required?** True; **Default**: ( No Default )

    A standard name for the exception raised.

  * **`p_errcode`** ::     **Required?** True; **Default**: ( No Default )

    Error code complying with the PostgreSQL standard error codes
    (https://www.postgresql.org/docs/current/errcodes-appendix.html).  Typically
    this will be a compatible error code made outside of already designated
    error codes.

  * **`p_param_data`** ::     **Required?** False; **Default**: ( No Default )

    A `jsonb` object where the keys are relevant parameters.

  * **`p_context_data`** ::     **Required?** False; **Default**: ( No Default )

    A `jsonb` object encapsulating relevant data which might help in
    interpreting the exception, if such data exists.
$DOC$;

        CREATE OR REPLACE FUNCTION <%= migrations_schema %>.trig_b_iu_set_diagnostic_columns()
        RETURNS trigger AS
        $BODY$

        -- File:        migration_schema_initialization.eex.sql
        -- Location:    msbms/priv/migrations_schema/migration_schema_initialization.eex.sql
        -- Project:     Muse Systems Business Management System
        --
        -- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
        -- This file may include content copyrighted and licensed from third parties.
        --
        -- See the LICENSE file in the project root for license terms and conditions.
        -- See the NOTICE file in the project root for copyright ownership information.
        --
        -- muse.information@musesystems.com  :: https://muse.systems

        BEGIN
            DECLARE
                var_jsonb_new        jsonb;
                var_jsonb_old        jsonb;
                var_jsonb_final      jsonb;

                bypass_change_fields boolean;

            BEGIN
                -- If this is an update and no actual data has changed, we don't want to
                -- pretend that something actually did change.  We set the flag here and
                -- later we bypass all of the fields indicating a real change.  We still
                -- update the diag_update_count field, because the database is still
                -- doing work in that scenario.
                bypass_change_fields := CASE
                                            WHEN tg_op = 'UPDATE' THEN
                                                to_jsonb( new ) = to_jsonb( old )
                                            ELSE
                                                FALSE
                                        END;

                -- Let's turn the new and old records into hstores so we can arbitrarily
                -- get their columns.  We also need to make the final hstore look a lot
                -- like NEW.
                var_jsonb_new := to_jsonb( new );
                var_jsonb_old := to_jsonb( old );

                var_jsonb_final := var_jsonb_new - ARRAY [ 'diag_timestamp_created'
                                                        ,'diag_role_created'
                                                        ,'diag_timestamp_modified'
                                                        ,'diag_wallclock_modified'
                                                        ,'diag_role_modified'
                                                        ,'diag_row_version'
                                                        ,'diag_update_count'];

                -- Now we can get some work done.
                CASE tg_op
                    WHEN 'INSERT' THEN
                        var_jsonb_final :=
                            var_jsonb_final ||
                            jsonb_build_object( 'diag_timestamp_created', now( ) );
                        var_jsonb_final :=
                            var_jsonb_final ||
                            jsonb_build_object( 'diag_role_created', session_user );
                        var_jsonb_final :=
                            var_jsonb_final ||
                            jsonb_build_object( 'diag_timestamp_modified', now( ) );
                        var_jsonb_final :=
                            var_jsonb_final ||
                            jsonb_build_object( 'diag_wallclock_modified',
                                                clock_timestamp( ) );
                        var_jsonb_final :=
                            var_jsonb_final ||
                            jsonb_build_object( 'diag_role_modified', session_user );
                        var_jsonb_final :=
                            var_jsonb_final ||
                            jsonb_build_object( 'diag_row_version', 1 );
                        var_jsonb_final :=
                            var_jsonb_final ||
                            jsonb_build_object( 'diag_update_count', 0 );

                    WHEN 'UPDATE' THEN
                        IF NOT bypass_change_fields THEN
                            var_jsonb_final :=
                                var_jsonb_final ||
                                jsonb_build_object( 'diag_timestamp_modified', now( ) );
                            var_jsonb_final :=
                                var_jsonb_final ||
                                jsonb_build_object( 'diag_wallclock_modified',
                                                    clock_timestamp( ) );
                            var_jsonb_final :=
                                var_jsonb_final ||
                                jsonb_build_object( 'diag_role_modified', session_user );
                            var_jsonb_final :=
                                var_jsonb_final ||
                                jsonb_build_object( 'diag_row_version',
                                                    ( var_jsonb_old -> 'diag_row_version' )::bigint  + 1 );
                        END IF;

                        var_jsonb_final :=
                            var_jsonb_final ||
                            jsonb_build_object( 'diag_update_count',
                                                ( var_jsonb_old -> 'diag_update_count' )::bigint  + 1 );

                ELSE
                    RAISE EXCEPTION
                        USING
                            MESSAGE = 'We should never get here.  The diagnostic column maintenance '
                                    'trigger was fired on something other than the insert/update of a '
                                    'regular record type.',
                            DETAIL = <%= migrations_schema %>.get_exception_details(
                                        p_proc_schema    => '<%= migrations_schema %>'
                                        ,p_proc_name      => 'trig_b_iu_set_diagnostic_columns'
                                        ,p_exception_name => 'unreachable_code_reached'
                                        ,p_errcode        => 'PM001'
                                        ,p_param_data     => NULL::jsonb
                                        ,p_context_data   =>
                                            jsonb_build_object(
                                                'tg_op',         tg_op
                                                ,'tg_when',       tg_when
                                                ,'tg_schema',     tg_table_schema
                                                ,'tg_table_name', tg_table_name)),
                            ERRCODE = 'PM001',
                            SCHEMA = tg_table_schema,
                            TABLE = tg_table_name;

                END CASE;

                -- We've done our jsonb magic, lets actually get a record to return...
                new := jsonb_populate_record( new, var_jsonb_final );

                RETURN new;

            END;
        END;
        $BODY$ LANGUAGE plpgsql
            VOLATILE;

        ALTER FUNCTION <%= migrations_schema %>.trig_b_iu_set_diagnostic_columns()
            OWNER TO <%= ms_owner %>;

        REVOKE EXECUTE ON FUNCTION <%= migrations_schema %>.trig_b_iu_set_diagnostic_columns() FROM public;
        GRANT EXECUTE ON FUNCTION <%= migrations_schema %>.trig_b_iu_set_diagnostic_columns() TO <%= ms_owner %>;


        COMMENT ON FUNCTION <%= migrations_schema %>.trig_b_iu_set_diagnostic_columns() IS
$DOC$Automatically maintains the common table diagnostic columns whenever data is
inserted or updated.

**General Usage**

For `UPDATE` transactions, the trigger will determine if there are 'real data
changes', meaning any fields other than the common diagnostic columns being
changed by the transaction.  If not, only the `diag_update_count` column will be
updated.

To use this trigger, the targeted table must have the following columns / types
defined:

  * `diag_timestamp_created` / `timestamptz`

  * `diag_role_created` / `text`

  * `diag_timestamp_modified` / `timestamptz`

  * `diag_wallclock_modified` / `timestamptz`

  * `diag_role_modified` / `text`

  * `diag_row_version` / `bigint`

  * `diag_update_count` / `bigint`
$DOC$;

        CREATE TABLE <%= migrations_schema %>.<%= migrations_table %>
        (
             id
                uuid
                NOT NULL DEFAULT uuid_generate_v7( )
                CONSTRAINT <%= migrations_table %>_pk PRIMARY KEY
            ,release
                smallint
                NOT NULL
                CONSTRAINT <%= migrations_table %>_release_range_chk
                    CHECK (release::integer <@ '[1, 1295]'::int4range)
            ,version
                smallint
                NOT NULL
                CONSTRAINT <%= migrations_table %>_version_range_chk
                    CHECK (version::integer <@ '[1, 1295]'::int4range)
            ,update
                integer
                NOT NULL
                CONSTRAINT <%= migrations_table %>_update_range_chk
                    CHECK (update <@ '[0, 46655]'::int4range)
            ,sponsor
                bigint
                NOT NULL
                CONSTRAINT <%= migrations_table %>_sponsor_range_chk
                    CHECK (sponsor <@ '[0, 2176782335]'::int8range)
            ,sponsor_modification
                integer
                NOT NULL
                CONSTRAINT <%= migrations_table %>_sponsor_modification_range_chk
                    CHECK (sponsor_modification <@ '[0, 46655]'::int4range)
            ,migration_version
                text
                NOT NULL
                CONSTRAINT <%= migrations_table %>_migration_version_udx UNIQUE
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

        ALTER TABLE <%= migrations_schema %>.<%= migrations_table %> OWNER TO <%= ms_owner %>;

        REVOKE ALL ON TABLE <%= migrations_schema %>.<%= migrations_table %> FROM public;
        GRANT ALL ON TABLE <%= migrations_schema %>.<%= migrations_table %> TO <%= ms_owner %>;

        CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
            BEFORE INSERT OR UPDATE ON <%= migrations_schema %>.<%= migrations_table %>
            FOR EACH ROW EXECUTE PROCEDURE <%= migrations_schema %>.trig_b_iu_set_diagnostic_columns();

        COMMENT ON
            TABLE <%= migrations_schema %>.<%= migrations_table %> IS
$DOC$Records which database updates have been applied to the system.

**General Usage**

Available database migrations are stored in a file system directory where
individual files are named starting with the version number taking a fixed
number of numeric digits.  In the simple case, the migration process will get a
sorted listing of available migrations from the migrations file system directory
and compare the version of the file with the minimum version number not already
checked against the maximum version applied to the database according to this
table.  If the file version is greater, the migration is applied to the
database, otherwise the file is skipped and the version checking process repeats
until there are no more migration files to evaluate.

Finally, during the migration process, the <%= migrations_schema %>.<%= migrations_table %>
record is created once the corresponding migration file has been successfully
applied to the database.  Both the migration file and the
<%= migrations_schema %>.<%= migrations_table %> record should be processed in the same
database transaction.$DOC$;

        COMMENT ON
            COLUMN <%= migrations_schema %>.<%= migrations_table %>.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

        COMMENT ON
            COLUMN <%= migrations_schema %>.<%= migrations_table %>.release IS
$DOC$The release number to which the migration applies.  The release number is any
value in the range of 1 to 1295 (01 - ZZ in base36 notation).  Release 00 is a
special value used by the application and should not be used for any other
purpose.$DOC$;

        COMMENT ON
            COLUMN <%= migrations_schema %>.<%= migrations_table %>.version IS
$DOC$The version of the release to which the migration applies.  Version numbers are
subordinate to releases.  The version number is any value in the range of 1 to
1295 (01 - ZZ in base36 notation).  Version 00 is a special value used by the
application and should not be used for any other purpose.$DOC$;

        COMMENT ON
            COLUMN <%= migrations_schema %>.<%= migrations_table %>.update IS
$DOC$The patch, or update, to the release version.  Update numbers are subordinate to
version numbers.  The update number may be any value in the range of 0 to 46655
(000 - ZZZ in base36 notation).$DOC$;

        COMMENT ON
            COLUMN <%= migrations_schema %>.<%= migrations_table %>.sponsor IS
$DOC$Identifies the entity that sponsored the development of the migration. The
expected value is in the range 0 to 2176782335 (0 - ZZZZZZ in base36 notation),
though there are additional rules which must be observed:

    -  Values in the range of 0 - 1295 (000000 - 0000ZZ) are reserved for Muse
    Systems special purposes.

    -  Value 820 (0000MS) identifies Muse Systems as the sponsor of the general
    availability software release and so will appear on all regularly
    released migrations.

    -  Values in the range of 1296 - 2176782335 are identifiers that are
    randomly assigned to clients and correspond to specific "instances"
    (application databases).  The primary instance for a client will always
    be the reference point for those clients with more than one instance.$DOC$;

        COMMENT ON
            COLUMN <%= migrations_schema %>.<%= migrations_table %>.sponsor_modification IS
$DOC$The specific migration implementing special or custom changes.  Sponsor
Modification numbers are subordinate to Update numbers.  The sponsor migration
number may be any value in the range of 0 to 46655 (000 - ZZZ in base36
notation).  In most cases this value will just be 0 (000).$DOC$;

        COMMENT ON
            COLUMN <%= migrations_schema %>.<%= migrations_table %>.migration_version IS
$DOC$The full migration version number represented as a series of digits in base 36
notation.  Each of the individual versioning fields are represented in a dot
separated notation: `RR.VV.UUU.CCCCCC.MMM`

  * `RR`     - Release Number
  * `VV`     - Version Number of the Release
  * `UUU`    - Update Number of the Version
  * `CCCCCC` - Client identifier for sponsored modifications
  * `MMM`    - Client specific modification sequence

This sequence is the same as the file name of each migration as saved in the
file system.  This field in the database is primarily for convenience of cross-
referencing applied migrations to the file system.$DOC$;

        COMMENT ON
            COLUMN <%= migrations_schema %>.<%= migrations_table %>.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

        COMMENT ON
            COLUMN <%= migrations_schema %>.<%= migrations_table %>.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

        COMMENT ON
            COLUMN <%= migrations_schema %>.<%= migrations_table %>.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

        COMMENT ON
            COLUMN <%= migrations_schema %>.<%= migrations_table %>.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

        COMMENT ON
            COLUMN <%= migrations_schema %>.<%= migrations_table %>.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

        COMMENT ON
            COLUMN <%= migrations_schema %>.<%= migrations_table %>.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

        COMMENT ON
            COLUMN <%= migrations_schema %>.<%= migrations_table %>.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;

    END;
$INIT_DATASTORE$;
