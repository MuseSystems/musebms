-- File:        test_data_unit_test.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_session/testing_support/test_data_unit_test.eex.sql
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
     ( 'get_session', jsonb_build_object('test_key', 'test_value'), now() + interval '1 hour')
    ,( 'expired_session', jsonb_build_object('expired_key', 'expired_value'), now() - interval '1 second')
    ,( 'update_session', jsonb_build_object('update_key', 'update_value'), now() + interval '1 hour')
    ,( 'update_session_date', jsonb_build_object('update_key', 'update_value'), now() + interval '1 hour')
    ,( 'delete_session', jsonb_build_object('delete_key', 'delete_value'), now() + interval '1 hour')
    ,( 'delete_expired_session', jsonb_build_object('delete_key', 'delete_value'), now() - interval '1 second')
    ,( 'example_session', jsonb_build_object('test_key', 'test_value'), now() + interval '1 hour')
    ,( 'example_expired_session', jsonb_build_object('expired_key', 'expired_value'), now() - interval '1 second')
    ,( 'example_update_session', jsonb_build_object('test_key', 'test_value'), now() + interval '1 hour')
    ,( 'example_delete_session', jsonb_build_object('test_key', 'test_value'), now() + interval '1 hour');
