
-- Source File: database_migrations.eex.sql
-- Location:    msbms/database/common/msbms_syst_data/tables/database_migrations.eex.sql
-- Project:     musebms
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE msbms_syst_data.database_migrations
(
     id                      uuid        DEFAULT uuid_generate_v1( ) NOT NULL
        CONSTRAINT database_migrations_pk PRIMARY KEY
    ,release                 smallint                                NOT NULL
        CONSTRAINT database_migrations_release_range_chk
        CHECK (release::integer <@ '[1, 1295]'::int4range)
    ,version                 smallint                                NOT NULL
        CONSTRAINT database_migrations_version_range_chk
        CHECK (version::integer <@ '[1, 1295]'::int4range)
    ,update                  integer                                 NOT NULL
        CONSTRAINT database_migrations_update_range_chk
        CHECK (update <@ '[0, 46655]'::int4range)
    ,sponsor                 bigint                                  NOT NULL
        CONSTRAINT database_migrations_sponsor_range_chk
        CHECK (sponsor <@ '[0, 2176782335]'::int8range)
    ,sponsor_modification    integer                                 NOT NULL
        CONSTRAINT database_migrations_sponsor_modification_range_chk
        CHECK (sponsor_modification <@ '[0, 46655]'::int4range)
    ,migration_version       text                                    NOT NULL
        CONSTRAINT database_migrations_migration_version_udx UNIQUE
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
    COLUMN msbms_syst_data.database_migrations.release IS
$DOC$The release number to which the migration applies.  The release number is any
value in the range of 1 to 1295 (01 - ZZ in base36 notation).  Release 00 is a
special value used by the application and should not be used for any other
purpose.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.database_migrations.version IS
$DOC$The version of the release to which the migration applies.  Version numbers are
subordinate to releases.  The version number is any value in the range of 1 to
1295 (01 - ZZ in base36 notation).  Version 00 is a special value used by the
application and should not be used for any other purpose.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.database_migrations.update IS
$DOC$The patch, or update, to the release version.  Update numbers are subordinate to
version numbers.  The update number may be any value in the range of 0 to 46655
(000 - ZZZ in base36 notation).$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.database_migrations.sponsor IS
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
    COLUMN msbms_syst_data.database_migrations.sponsor_modification IS
$DOC$The specific migration implementing special or custom changes.  Sponsor
Modification numbers are subordinate to Update numbers.  The sponsor migration
number may be any value in the range of 0 to 46655 (000 - ZZZ in base36
notation).  In most cases this value will just be 0 (000).$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.database_migrations.migration_version IS
$DOC$The full migration version number represented as a series of digits in base 36
notation.  Each of the individual versioning fields are represented in a dot
separated notation:  RR.VV.UUU.CCCCCC.MMM

    RR     = Release Number
    VV     = Version Number of the Release
    UUU    = Update Number of the Version
    CCCCCC = Client identifier for sponsored modifications
    MMM    = Client specific modification sequence

This sequence is the same as the file name of each migration as saved in the
file system.  This field in the database is primarily for convenience of cross-
referencing applied migrations to the file system.$DOC$;

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
