-- File:        mstr_customer_relationships.sql
-- Location:    msbms/database/msbms_appl_data/tables/mstr_customer_relationships.sql
-- Project:     Muse Systems Business Management System
--
-- Licensed to Lima Buttgereit Holdings LLC (d/b/a Muse Systems) under one or
-- more agreements.  Muse Systems licenses this file to you under the terms and
-- conditions of your Muse Systems Master Services Agreement or governing
-- Statement of Work.
--
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE msbms_appl_data.mstr_customer_relationships
(
     id                          uuid        DEFAULT uuid_generate_v1( ) NOT NULL
        CONSTRAINT mstr_customer_relationships_pk PRIMARY KEY
    ,entity_id                   uuid                                    NOT NULL
        CONSTRAINT mstr_customer_relationships_entity_id_fk
        REFERENCES msbms_appl_data.mstr_entities (id)
        ON DELETE CASCADE
    ,owning_entity_id            uuid                                    NOT NULL
        CONSTRAINT mstr_customer_relationships_owning_entity_id_fk
        REFERENCES msbms_appl_data.mstr_entities (id)
        ON DELETE CASCADE
    ,diag_timestamp_created      timestamptz DEFAULT now( )              NOT NULL
    ,diag_role_created           text                                    NOT NULL
    ,diag_timestamp_modified     timestamptz DEFAULT now( )              NOT NULL
    ,diag_wallclock_modified     timestamptz DEFAULT clock_timestamp( )  NOT NULL
    ,diag_role_modified          text                                    NOT NULL
    ,diag_row_version            bigint      DEFAULT 1                   NOT NULL
    ,diag_update_count           bigint      DEFAULT 0                   NOT NULL
    ,CONSTRAINT mstr_customer_relationship_entities_udx
        UNIQUE (entity_id, owning_entity_id)
);

ALTER TABLE msbms_appl_data.mstr_customer_relationships OWNER TO msbms_owner;

REVOKE ALL ON TABLE msbms_appl_data.mstr_customer_relationships FROM public;
GRANT ALL ON TABLE msbms_appl_data.mstr_customer_relationships TO msbms_owner;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON msbms_appl_data.mstr_customer_relationships
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE msbms_appl_data.mstr_customer_relationships IS
$DOC$Establishes a customer relationship between an owning entity and its customer
entity.  This record, or its children, will define sales and receivables
behavior when the transaction entity is the owning entity.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_customer_relationships.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_customer_relationships.entity_id IS
$DOC$Identifies for which entity customer details are being defined.  The terms
in this record define the customer behavior for the entity defined by this
field.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_customer_relationships.owning_entity_id IS
$DOC$Identifies the entity that will use the customer terms when processing
selling and receivables transactions with the entity identified in the
mstr_entity_id field.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_customer_relationships.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_customer_relationships.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_customer_relationships.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_customer_relationships.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_customer_relationships.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_customer_relationships.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_customer_relationships.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
