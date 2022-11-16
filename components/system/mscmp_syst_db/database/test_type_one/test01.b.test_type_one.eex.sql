-- File:        test01.b.test_type_one.eex.sql
-- Location:    musebms/components\system\mscmp_syst_db\database\test_type_one\test01.b.test_type_one.eex.sql
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
CREATE TABLE msbms_test.test_type_one
(
     id                      uuid        DEFAULT uuid_generate_v1( ) NOT NULL
        CONSTRAINT test_type_one_pk PRIMARY KEY
    ,test_value              text                                    NOT NULL
);

ALTER TABLE msbms_test.test_type_one OWNER TO <%= msbms_owner %>;

REVOKE ALL ON TABLE msbms_test.test_type_one FROM public;
GRANT ALL ON TABLE msbms_test.test_type_one TO <%= msbms_owner %>;

COMMENT ON
    TABLE msbms_test.test_type_one IS
$DOC$A test table created by test01.b.test_type_one.eex.sql$DOC$;

COMMENT ON
    COLUMN msbms_test.test_type_one.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN  msbms_test.test_type_one.test_value IS
$DOC$A test value to be tested.$DOC$;
