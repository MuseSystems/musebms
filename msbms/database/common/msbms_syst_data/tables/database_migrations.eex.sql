
-- Source File: database_migrations.eex.sql
-- Location:    msbms/database/common/msbms_syst_data/tables/database_migrations.eex.sql
-- Project:     musebms
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from thrid parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE msbms_syst_data.database_migrations
(
     id                      uuid        DEFAULT uuid_generate_v1( ) NOT NULL
        CONSTRAINT database_migrations_pk PRIMARY KEY
    ,migration_release       bigint                                  NOT NULL
    ,migration_version       bigint                                  NOT NULL
    ,migration_update        bigint                                  NOT NULL
    ,diag_timestamp_created  timestamptz DEFAULT now( )              NOT NULL
    ,diag_role_created       text                                    NOT NULL
    ,diag_timestamp_modified timestamptz DEFAULT now( )              NOT NULL
    ,diag_wallclock_modified timestamptz DEFAULT clock_timestamp( )  NOT NULL
    ,diag_role_modified      text                                    NOT NULL
    ,diag_row_version        bigint      DEFAULT 1                   NOT NULL
    ,diag_update_count       bigint      DEFAULT 0                   NOT NULL
);

ALTER TABLE msbms_syst_data.database_migrations OWNER TO <%= msbms_owner %>;

REVOKE ALL ON TABLE msbms_syst_data.database_migrations FROM public;
GRANT ALL ON TABLE msbms_syst_data.database_migrations TO <%= msbms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON msbms_syst_data.database_migrations
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE msbms_syst_data.database_migrations IS
$DOC$Records which database updates have been applied to the system.  Available
database migrations are stored in a file system directory where individual files
are named starting with the version number taking a fixed number of numeric
digits.  In the simple case, the migration process will get a sorted listing of
available migrations from the migrations file system directory and compare the
version of the file with the minimum version number not already checked against
the maximum version applied to the database according to this table.  If the
file version is greater, the migration is applied to the database, otherwise the
file is skipped and the version checking process repeats until there are no more
migration files to evaluate.

Finally, during the migration process, the msbms_syst_data.database_migrations
record is created once the corresponding migration file has been successfully
applied to the database.  Both the migration file and the
msbms_syst_data.database_migrations record should be processed in the same
database transaction.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.database_migrations.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.database_migrations.migration_release IS
$DOC$The release number to which the migration applies.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.database_migrations.migration_version IS
$DOC$The version of the release to which the migration applies.  Version numbers are
subordinate to releases.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.database_migrations.migration_update IS
$DOC$The patch, or update, to the release version.  Update numbers are subordinate to
version numbers.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.database_migrations.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.database_migrations.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.database_migrations.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.database_migrations.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.database_migrations.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.database_migrations.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.database_migrations.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
