-- File:        trig_b_iu_set_diagnostic_columns.sql
-- Location:    msbms/database/msbms_syst_priv/trigger_functions/trig_b_iu_set_diagnostic_columns.sql
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

CREATE OR REPLACE FUNCTION msbms_syst_priv.trig_b_iu_set_diagnostic_columns()
RETURNS trigger AS
$BODY$
BEGIN
    DECLARE
        var_jsonb_new        jsonb;
        var_jsonb_old        jsonb;
        var_jsonb_final      jsonb;

        bypass_change_fields boolean;

    BEGIN
        -- If this is an update and no actual data has changed, we don't want to
        -- pretend that something actually did change.  We set the flag here and
        -- later we bypass all of the fields indicating a real change.  We still
        -- update the diag_update_count field, because the database is still
        -- doing work in that scenario.
        bypass_change_fields := CASE
                                    WHEN tg_op = 'UPDATE' THEN
                                        to_jsonb( new ) = to_jsonb( old )
                                    ELSE
                                        FALSE
                                END;

        -- Let's turn the new and old records into hstores so we can arbitrarily
        -- get their columns.  We also need to make the final hstore look a lot
        -- like NEW.
        var_jsonb_new := to_jsonb( new );
        var_jsonb_old := to_jsonb( old );

        var_jsonb_final := var_jsonb_new - ARRAY [ 'diag_timestamp_created'
                                                  ,'diag_role_created'
                                                  ,'diag_timestamp_modified'
                                                  ,'diag_wallclock_modified'
                                                  ,'diag_role_modified'
                                                  ,'diag_row_version'
                                                  ,'diag_update_count'];

        -- Now we can get some work done.
        CASE tg_op
            WHEN 'INSERT' THEN
                var_jsonb_final :=
                    var_jsonb_final ||
                    jsonb_build_object( 'diag_timestamp_created', now( ) );
                var_jsonb_final :=
                    var_jsonb_final ||
                    jsonb_build_object( 'diag_role_created', session_user );
                var_jsonb_final :=
                    var_jsonb_final ||
                    jsonb_build_object( 'diag_timestamp_modified', now( ) );
                var_jsonb_final :=
                    var_jsonb_final ||
                    jsonb_build_object( 'diag_wallclock_modified',
                                        clock_timestamp( ) );
                var_jsonb_final :=
                    var_jsonb_final ||
                    jsonb_build_object( 'diag_role_modified', session_user );
                var_jsonb_final :=
                    var_jsonb_final ||
                    jsonb_build_object( 'diag_row_version', 1 );
                var_jsonb_final :=
                    var_jsonb_final ||
                    jsonb_build_object( 'diag_update_count', 0 );

            WHEN 'UPDATE' THEN
                IF NOT bypass_change_fields THEN
                    var_jsonb_final :=
                        var_jsonb_final ||
                        jsonb_build_object( 'diag_timestamp_modified', now( ) );
                    var_jsonb_final :=
                        var_jsonb_final ||
                        jsonb_build_object( 'diag_wallclock_modified',
                                            clock_timestamp( ) );
                    var_jsonb_final :=
                        var_jsonb_final ||
                        jsonb_build_object( 'diag_role_modified', session_user );
                    var_jsonb_final :=
                        var_jsonb_final ||
                        jsonb_build_object( 'diag_row_version',
                                            ( var_jsonb_old -> 'diag_row_version' )::bigint  + 1 );
                END IF;

                var_jsonb_final :=
                    var_jsonb_final ||
                    jsonb_build_object( 'diag_update_count',
                                        ( var_jsonb_old -> 'diag_update_count' )::bigint  + 1 );

        ELSE
            RAISE EXCEPTION
                USING
                    MESSAGE = 'We should never get here.  The diagnostic column maintenance '
                              'trigger was fired on something other than the insert/update of a '
                              'regular record type.',
                    DETAIL = msbms_syst_priv.get_exception_details(
                                 p_proc_schema    => 'msbms_syst_priv'
                                ,p_proc_name      => 'trig_b_iu_set_diagnostic_columns'
                                ,p_exception_name => 'unreachable_code_reached'
                                ,p_errcode        => 'PM001'
                                ,p_param_data     => NULL::jsonb
                                ,p_context_data   =>
                                    jsonb_build_object(
                                         'tg_op',         tg_op
                                        ,'tg_when',       tg_when
                                        ,'tg_schema',     tg_table_schema
                                        ,'tg_table_name', tg_table_name)),
                    ERRCODE = 'PM001',
                    SCHEMA = tg_table_schema,
                    TABLE = tg_table_name;

        END CASE;

        -- We've done our jsonb magic, lets actually get a record to return...
        new := jsonb_populate_record( new, var_jsonb_final );

        RETURN new;

    END;
END;
$BODY$ LANGUAGE plpgsql
    VOLATILE;

ALTER FUNCTION msbms_syst_priv.trig_b_iu_set_diagnostic_columns()
    OWNER TO msbms_owner;

REVOKE EXECUTE ON FUNCTION msbms_syst_priv.trig_b_iu_set_diagnostic_columns() FROM public;
GRANT EXECUTE ON FUNCTION msbms_syst_priv.trig_b_iu_set_diagnostic_columns() TO msbms_owner;


COMMENT ON FUNCTION msbms_syst_priv.trig_b_iu_set_diagnostic_columns() IS
$DOC$Automatically maintains the common table diagnostic columns whenever data is
inserted or updated.  For UPDATE transactions, the trigger will determine if
there are 'real data changes', meaning any fields other than the common
diagnostic columns being changed by the transaction.  If not, only the
diag_update_count column will be updated.$DOC$;
