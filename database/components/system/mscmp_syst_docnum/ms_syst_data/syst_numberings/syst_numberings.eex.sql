-- File:        syst_numberings.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_docnum/ms_syst_data/syst_numberings/syst_numberings.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_numberings
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v7( )
        CONSTRAINT syst_numberings_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_numberings_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT syst_numberings_display_name_udx UNIQUE
    ,syst_description
        text
        NOT NULL
    ,user_description
        text
    ,feature_id
        uuid
        NOT NULL
        CONSTRAINT syst_numberings_feature_fk
            REFERENCES ms_syst_data.syst_feature_map (id)
    ,syst_defined
        boolean
        NOT NULL DEFAULT FALSE
    ,user_maintainable
        boolean
        NOT NULL DEFAULT TRUE
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
);

ALTER TABLE ms_syst_data.syst_numberings OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_numberings FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_numberings TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_numberings
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE ms_syst_data.syst_numberings IS
$DOC$Records the available numbering sequences in the system.  These may be system
created or user created.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numberings.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numberings.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numberings.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numberings.syst_description IS
$DOC$A default description of the numbering which might include details such as how
the numbering is used.

Note that users should not change this value.  For custom descriptions, use the
ms_syst_data.syst_numberings.user_description field instead.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numberings.user_description IS
$DOC$A user defined description of the numbering to support custom user documentation
of the purpose and function of the numbering.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numberings.feature_id IS
$DOC$A reference to the specific feature of which the numbering is considered to be
part.  This reference is chiefly used to determine where in the configuration
options the numbering should appear.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numberings.syst_defined IS
$DOC$If true, this value indicates that the numbering is considered part of the
application.  Often times, system numberings are manageable by users, but the
existence of the numbering in the system is assumed to exist by the
application.  If false, the assumption is that the numbering was created by
users and supports custom user functionality.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numberings.user_maintainable IS
$DOC$When true, this column indicates that the numbering is user maintainable;
this might include the ability to add, edit, or remove numbering values such as
segments.  When false, the numbering is strictly system managed for any
functional purpose.  Note that the value of this column doesn't effect the
ability to set a user_description value; the ability to set custom descriptions
is always available for any properly authorized user.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numberings.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numberings.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numberings.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numberings.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numberings.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numberings.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numberings.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
