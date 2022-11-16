-- File:        test01.b.test_type_four.eex.sql
-- Location:    musebms/components/system/mscmp_syst_db/database/migration_test/test_type_four/test01.b.test_type_four.eex.sql
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
CREATE TABLE msbms_test.test_type_four
(
     id                      uuid        DEFAULT uuid_generate_v1( ) NOT NULL
        CONSTRAINT test_type_four_pk PRIMARY KEY
    ,test_value              text                                    NOT NULL
);

ALTER TABLE msbms_test.test_type_four OWNER TO <%= msbms_owner %>;

REVOKE ALL ON TABLE msbms_test.test_type_four FROM public;
GRANT ALL ON TABLE msbms_test.test_type_four TO <%= msbms_owner %>;
GRANT ALL ON TABLE msbms_test.test_type_four TO msbms_type_four_role_01;

COMMENT ON
    TABLE msbms_test.test_type_four IS
$DOC$A test table created by test01.b.test_type_four.eex.sql$DOC$;

COMMENT ON
    COLUMN msbms_test.test_type_four.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN  msbms_test.test_type_four.test_value IS
$DOC$A test value to be tested.$DOC$;
