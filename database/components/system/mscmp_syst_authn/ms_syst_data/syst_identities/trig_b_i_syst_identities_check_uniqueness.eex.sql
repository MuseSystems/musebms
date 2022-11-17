CREATE OR REPLACE FUNCTION ms_syst_data.trig_b_i_syst_identities_validate_uniqueness()
RETURNS trigger AS
$BODY$

-- File:        trig_b_i_syst_identities_check_uniqueness.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst_data/syst_identities/trig_b_i_syst_identities_check_uniqueness.eex.sql
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
    -- TODO: This trigger may be replaced by a unique index once PostgreSQL 15
    --       becomes our standard.  That version will allow the option to treat
    --       null values as a single value rather than each null distinct from
    --       all others, which matches our resolution scope definition here.
    IF
        exists( SELECT
                    TRUE
                FROM ms_syst_data.syst_access_accounts saa_this
                    LEFT JOIN ms_syst_data.syst_access_accounts saa_other
                          ON saa_this.owning_owner_id IS NOT DISTINCT FROM saa_other.owning_owner_id AND
                             saa_this.id IS DISTINCT FROM saa_other.id
                    LEFT JOIN ms_syst_data.syst_identities si_any
                          ON ( si_any.access_account_id = saa_other.id OR
                               si_any.access_account_id = saa_this.id ) AND
                             si_any.identity_type_id = new.identity_type_id
                WHERE
                      saa_this.id = new.access_account_id
                  AND si_any.account_identifier = new.account_identifier
            )
    THEN

        RAISE EXCEPTION
            USING
                MESSAGE = 'The identity already matches that of a different access account '
                          'in the same scope of identity resolution.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst_data'
                            ,p_proc_name      => 'trig_b_i_syst_identities_validate_uniqueness'
                            ,p_exception_name => 'duplicate_identity'
                            ,p_errcode        => 'PM002'
                            ,p_param_data     => jsonb_build_object(
                                 'access_account_id', new.access_account_id
                                ,'account_identifier', new.account_identifier
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

ALTER FUNCTION ms_syst_data.trig_b_i_syst_identities_validate_uniqueness()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_data.trig_b_i_syst_identities_validate_uniqueness() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_data.trig_b_i_syst_identities_validate_uniqueness() TO <%= ms_owner %>;


COMMENT ON FUNCTION ms_syst_data.trig_b_i_syst_identities_validate_uniqueness() IS
$DOC$Provides a check that each ms_syst_data.syst_identities.account_identifier
value is unique for each owner's access accounts or unique amongst unowned
access accounts.$DOC$;
