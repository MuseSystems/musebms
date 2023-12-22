-- File:        test01.b.test_type_three.eex.sql
-- Location:    musebms/components/system/mscmp_syst_db/database/alt_database/test_type_three/test01.b.test_type_three.eex.sql
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
CREATE TABLE ms_test.test_type_three
(
     id                      uuid        DEFAULT uuid_generate_v7( ) NOT NULL
        CONSTRAINT test_type_three_pk PRIMARY KEY
    ,test_value              text                                    NOT NULL
);

ALTER TABLE ms_test.test_type_three OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_test.test_type_three FROM public;
GRANT ALL ON TABLE ms_test.test_type_three TO <%= ms_owner %>;

COMMENT ON
    TABLE ms_test.test_type_three IS
$DOC$A test table created by test01.b.test_type_three.eex.sql$DOC$;

COMMENT ON
    COLUMN ms_test.test_type_three.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN  ms_test.test_type_three.test_value IS
$DOC$A test value to be tested.$DOC$;
