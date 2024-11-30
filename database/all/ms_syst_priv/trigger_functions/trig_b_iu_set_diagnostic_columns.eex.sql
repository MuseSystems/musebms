CREATE OR REPLACE FUNCTION ms_syst_priv.trig_b_iu_set_diagnostic_columns()
RETURNS trigger AS
$BODY$

-- File:        trig_b_iu_set_diagnostic_columns.eex.sql
-- Location:    musebms/database/all/ms_syst_priv/trigger_functions/trig_b_iu_set_diagnostic_columns.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

BEGIN
    DECLARE
        v_jsonb_new        jsonb;
        v_jsonb_old        jsonb;
        v_jsonb_final      jsonb;

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

        v_jsonb_new := to_jsonb( new );
        v_jsonb_old := to_jsonb( old );

        v_jsonb_final := v_jsonb_new - ARRAY [ 'diag_timestamp_created'
                                                  ,'diag_role_created'
                                                  ,'diag_timestamp_modified'
                                                  ,'diag_wallclock_modified'
                                                  ,'diag_role_modified'
                                                  ,'diag_row_version'
                                                  ,'diag_update_count'];

        CASE tg_op
            WHEN 'INSERT' THEN
                v_jsonb_final :=
                    v_jsonb_final ||
                    jsonb_build_object( 'diag_timestamp_created', now( ) );
                v_jsonb_final :=
                    v_jsonb_final ||
                    jsonb_build_object( 'diag_role_created', session_user );
                v_jsonb_final :=
                    v_jsonb_final ||
                    jsonb_build_object( 'diag_timestamp_modified', now( ) );
                v_jsonb_final :=
                    v_jsonb_final ||
                    jsonb_build_object( 'diag_wallclock_modified',
                                        clock_timestamp( ) );
                v_jsonb_final :=
                    v_jsonb_final ||
                    jsonb_build_object( 'diag_role_modified', session_user );
                v_jsonb_final :=
                    v_jsonb_final ||
                    jsonb_build_object( 'diag_row_version', 1 );
                v_jsonb_final :=
                    v_jsonb_final ||
                    jsonb_build_object( 'diag_update_count', 0 );

            WHEN 'UPDATE' THEN
                IF NOT bypass_change_fields THEN
                    v_jsonb_final :=
                        v_jsonb_final ||
                        jsonb_build_object( 'diag_timestamp_modified', now( ) );
                    v_jsonb_final :=
                        v_jsonb_final ||
                        jsonb_build_object( 'diag_wallclock_modified',
                                            clock_timestamp( ) );
                    v_jsonb_final :=
                        v_jsonb_final ||
                        jsonb_build_object( 'diag_role_modified', session_user );
                    v_jsonb_final :=
                        v_jsonb_final ||
                        jsonb_build_object( 'diag_row_version',
                                            ( v_jsonb_old -> 'diag_row_version' )::bigint  + 1 );
                END IF;

                v_jsonb_final :=
                    v_jsonb_final ||
                    jsonb_build_object( 'diag_update_count',
                                        ( v_jsonb_old -> 'diag_update_count' )::bigint  + 1 );

        ELSE
            RAISE EXCEPTION
                USING
                    MESSAGE = 'We should never get here.  The diagnostic column maintenance '
                              'trigger was fired on something other than the insert/update of a '
                              'regular record type.',
                    DETAIL = ms_syst_priv.get_exception_details(
                                 p_proc_schema    => 'ms_syst_priv'
                                ,p_proc_name      => 'trig_b_iu_set_diagnostic_columns'
                                ,p_param_data     => NULL::jsonb
                                ,p_context_data   =>
                                    jsonb_build_object(
                                         'tg_op',         tg_op
                                        ,'tg_when',       tg_when
                                        ,'tg_schema',     tg_table_schema
                                        ,'tg_table_name', tg_table_name)),
                    ERRCODE = 'PM901',
                    SCHEMA = tg_table_schema,
                    TABLE = tg_table_name;

        END CASE;

        new := jsonb_populate_record( new, v_jsonb_final );

        RETURN new;

    END;
END;
$BODY$ LANGUAGE plpgsql
    VOLATILE;

ALTER FUNCTION ms_syst_priv.trig_b_iu_set_diagnostic_columns()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_priv.trig_b_iu_set_diagnostic_columns() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_priv.trig_b_iu_set_diagnostic_columns() TO <%= ms_owner %>;

DO
$DOCUMENTATION$
DECLARE
    -- Function
    v_comments_config ms_syst_priv.comments_config_function;

BEGIN

    --
    -- Function Config
    --

    v_comments_config.function_schema := 'ms_syst_priv';
    v_comments_config.function_name   := 'trig_b_iu_set_diagnostic_columns';

    v_comments_config.trigger_function := TRUE;
    v_comments_config.trigger_timing   := ARRAY [ 'b' ]::text[ ];
    v_comments_config.trigger_ops      := ARRAY [ 'i', 'u' ]::text[ ];

    v_comments_config.description :=
$DOC$Automatically maintains the common table diagnostic columns whenever data is
inserted or updated.$DOC$;

    v_comments_config.general_usage :=
$DOC$For `UPDATE` transactions, the trigger will determine if there are 'real data
changes', meaning any fields other than the common diagnostic columns being
changed by the transaction.  If not, only the `diag_update_count` column will be
updated.

To use this trigger, the targeted table must have the following columns / types
defined:

  * `diag_timestamp_created` / `timestamptz`

  * `diag_role_created` / `text`

  * `diag_timestamp_modified` / `timestamptz`

  * `diag_wallclock_modified` / `timestamptz`

  * `diag_role_modified` / `text`

  * `diag_row_version` / `bigint`

  * `diag_update_count` / `bigint`
$DOC$;

    PERFORM ms_syst_priv.generate_comments_function( v_comments_config );

END;
$DOCUMENTATION$;
