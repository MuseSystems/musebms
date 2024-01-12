-- File:        test_data_doc_test.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_session/testing_support/test_data_doc_test.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

INSERT INTO ms_syst_data.syst_sessions
    (internal_name, session_data, session_expires)
VALUES
     ( 'example_session', jsonb_build_object('test_key', 'test_value'), now() + interval '1 hour')
    ,( 'example_expired_session', jsonb_build_object('expired_key', 'expired_value'), now() - interval '1 second')
    ,( 'example_update_session', jsonb_build_object('test_key', 'test_value'), now() + interval '1 hour')
    ,( 'example_delete_session', jsonb_build_object('test_key', 'test_value'), now() + interval '1 hour');
