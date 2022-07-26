CREATE OR REPLACE FUNCTION msbms_syst_data.trig_b_iu_syst_identities_validate_uniqueness()
RETURNS trigger AS
$BODY$

-- File:        trig_b_iu_syst_identities_check_uniqueness.eex.sql
-- Location:    database\app_msbms_global\mod_authentication\msbms_syst_data\syst_identities\trig_b_iu_syst_identities_check_uniqueness.eex.sql
-- Project:     Muse Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

BEGIN

    IF
        exists(
            SELECT true
            FROM msbms_syst_data.syst_access_accounts saa_this
                LEFT JOIN msbms_syst_data.syst_access_accounts saa_other
                    ON saa_this.owning_owner_id IS NOT DISTINCT FROM saa_other.owning_owner_id AND
                       saa_this.id IS DISTINCT FROM saa_other.id
                LEFT JOIN msbms_syst_data.syst_identities si_other
                    ON si_other.access_account_id = saa_other.id AND
                       si_other.identity_type_id = new.identity_type_id
            WHERE saa_this.id = new.access_acount_id AND
                  si_other.identifier = new.identifier
            )
    THEN

        RAISE EXCEPTION
            USING
                MESSAGE = 'The identity already matches that of a different access account '
                          'in the same scope of identity resolution.',
                DETAIL = msbms_syst_priv.get_exception_details(
                             p_proc_schema    => 'msbms_syst_data'
                            ,p_proc_name      => 'trig_b_iu_syst_identities_validate_uniqueness'
                            ,p_exception_name => 'duplicate_identity'
                            ,p_errcode        => 'PM002'
                            ,p_param_data     => jsonb_build_object(
                                 'access_account_id', new.access_account_id
                                ,'identifier', new.identifier
                            )
                            ,p_context_data   =>
                                jsonb_build_object(
                                     'tg_op',         tg_op
                                    ,'tg_when',       tg_when
                                    ,'tg_schema',     tg_table_schema
                                    ,'tg_table_name', tg_table_name)),
                ERRCODE = 'PM002',
                SCHEMA = tg_table_schema,
                TABLE = tg_table_name;

    END IF;

    RETURN NEW;

END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION msbms_syst_data.trig_b_iu_syst_identities_validate_uniqueness()
    OWNER TO <%= msbms_owner %>;

REVOKE EXECUTE ON FUNCTION msbms_syst_data.trig_b_iu_syst_identities_validate_uniqueness() FROM public;
GRANT EXECUTE ON FUNCTION msbms_syst_data.trig_b_iu_syst_identities_validate_uniqueness() TO <%= msbms_owner %>;


COMMENT ON FUNCTION msbms_syst_data.trig_b_iu_syst_identities_validate_uniqueness() IS
$DOC$Provides a check that each msbms_syst_data.syst_identities.identifier value is unique for each
owner's access accounts or unique amongst unowned access accounts.$DOC$;
