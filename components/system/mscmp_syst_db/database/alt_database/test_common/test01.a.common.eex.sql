-- File:        test01.a.common.eex.sql
-- Location:    musebms/components/system/mscmp_syst_db/database/alt_database/test_common/test01.a.common.eex.sql
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

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE SCHEMA msbms_test AUTHORIZATION <%= msbms_owner %>;

CREATE TABLE msbms_test.common
(
     id                      uuid        DEFAULT uuid_generate_v1( ) NOT NULL
        CONSTRAINT common_pk PRIMARY KEY
    ,test_value              text                                    NOT NULL
);

ALTER TABLE msbms_test.common OWNER TO <%= msbms_owner %>;

REVOKE ALL ON TABLE msbms_test.common FROM public;
GRANT ALL ON TABLE msbms_test.common TO <%= msbms_owner %>;

COMMENT ON
    TABLE msbms_test.common IS
$DOC$A test table created by test01.a.common.eex.sql$DOC$;

COMMENT ON
    COLUMN msbms_test.common.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN  msbms_test.common.test_value IS
$DOC$A test value to be tested.$DOC$;

INSERT INTO msbms_test.common
    (test_value)
VALUES
     ('Test 01')
    ,('Test 02')
    ,('Test 03');
