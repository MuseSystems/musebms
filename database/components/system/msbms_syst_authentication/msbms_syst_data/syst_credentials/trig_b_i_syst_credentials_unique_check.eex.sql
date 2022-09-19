CREATE OR REPLACE FUNCTION msbms_syst_data.trig_b_i_syst_credentials_unique_check()
RETURNS trigger AS
$BODY$

-- File:        trig_b_i_syst_credentials_unique_check.eex.sql
-- Location:    musebms/database/components/system/msbms_syst_authentication/msbms_syst_data/syst_credentials/trig_b_i_syst_credentials_unique_check.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

DECLARE

BEGIN

    -- The current uniqueness requirement states that syst_credential records
    -- are unique by access_account_id, credential_type_id, and
    -- credential_for_identity_id.  In PostgreSQL versions 14 and earlier, this
    -- cannot be achieved by a unique constraint since
    -- credential_for_identity_id may be NULL (password credentials for example)
    -- and PostgreSQL will treat all NULLs as individually unique.  In
    -- the coming PostgreSQL 15, NULL treatment for uniqueness will be
    -- configurable which will negate the need for this trigger should the
    -- feature land on release.

    IF
        exists( SELECT
                    TRUE
                FROM msbms_syst_data.syst_credentials
                WHERE
                      access_account_id = new.access_account_id
                  AND credential_type_id = new.credential_type_id
                  AND credential_for_identity_id IS NOT DISTINCT FROM new.credential_for_identity_id )
    THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'Credentials must be unique by access_account_id, credential_type_id, ' ||
                          'and credential_for_identity_id where NULL is considered a non-unique ' ||
                          'value.',
                DETAIL = msbms_syst_priv.get_exception_details(
                             p_proc_schema    => 'msbms_syst_data'
                            ,p_proc_name      => 'trig_b_i_syst_credentials_unique_check'
                            ,p_exception_name => 'uniqueness_violation'
                            ,p_errcode        => 'PM008'
                            ,p_param_data     => jsonb_build_object('new', new)
                            ,p_context_data   =>
                                jsonb_build_object(
                                     'tg_op',         tg_op
                                    ,'tg_when',       tg_when
                                    ,'tg_schema',     tg_table_schema
                                    ,'tg_table_name', tg_table_name)),
                ERRCODE = 'PM008',
                SCHEMA = tg_table_schema,
                TABLE = tg_table_name;
    END IF;

    RETURN new;

END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION msbms_syst_data.trig_b_i_syst_credentials_unique_check()
    OWNER TO <%= msbms_owner %>;

REVOKE EXECUTE ON FUNCTION msbms_syst_data.trig_b_i_syst_credentials_unique_check() FROM public;
GRANT EXECUTE ON FUNCTION msbms_syst_data.trig_b_i_syst_credentials_unique_check() TO <%= msbms_owner %>;

COMMENT ON FUNCTION msbms_syst_data.trig_b_i_syst_credentials_unique_check() IS
$DOC$Enforces the required uniqueness of syst_credential records.$DOC$;
