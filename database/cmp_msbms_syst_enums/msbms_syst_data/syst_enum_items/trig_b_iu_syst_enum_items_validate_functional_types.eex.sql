CREATE OR REPLACE FUNCTION msbms_syst_data.trig_b_iu_syst_enum_items_validate_functional_types()
RETURNS trigger AS
$BODY$

-- File:        trig_b_iu_syst_enum_items_validate_functional_types.eex.sql
-- Location:    musebms/database/cmp_msbms_syst_enums/msbms_syst_data/syst_enum_items/trig_b_iu_syst_enum_items_validate_functional_types.eex.sql
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

    IF
        EXISTS( SELECT TRUE
                FROM msbms_syst_data.syst_enum_functional_types seft
                WHERE   seft.enum_id = new.enum_id) AND
        NOT EXISTS( SELECT TRUE
                    FROM msbms_syst_data.syst_enum_functional_types seft
                    WHERE   seft.id = new.functional_type_id
                        AND seft.enum_id = new.enum_id)
    THEN

        RAISE EXCEPTION
            USING
                MESSAGE = 'The enumeration requires a valid functional type to be specified.',
                DETAIL  = msbms_syst_priv.get_exception_details(
                             p_proc_schema    => 'msbms_syst_data'
                            ,p_proc_name      => 'trig_b_iu_syst_enum_items_validate_functional_types'
                            ,p_exception_name => 'invalid_functional_type'
                            ,p_errcode        => 'PM003'
                            ,p_param_data     => to_jsonb(new)
                            ,p_context_data   =>
                                jsonb_build_object(
                                     'tg_op',         tg_op
                                    ,'tg_when',       tg_when
                                    ,'tg_schema',     tg_table_schema
                                    ,'tg_table_name', tg_table_name)),
                ERRCODE = 'PM003',
                SCHEMA  = tg_table_schema,
                TABLE   = tg_table_name;

    END IF;

    RETURN new;
END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION msbms_syst_data.trig_b_iu_syst_enum_items_validate_functional_types()
    OWNER TO <%= msbms_owner %>;

REVOKE EXECUTE ON FUNCTION msbms_syst_data.trig_b_iu_syst_enum_items_validate_functional_types() FROM public;
GRANT EXECUTE ON FUNCTION msbms_syst_data.trig_b_iu_syst_enum_items_validate_functional_types() TO <%= msbms_owner %>;

COMMENT ON FUNCTION msbms_syst_data.trig_b_iu_syst_enum_items_validate_functional_types() IS
$DOC$Ensures that if the parent syst_enums record has syst_enum_functional_types
records defined, a syst_enum_items record will reference one of those
functional types.  Note that this trigger function is intended to be use by
constraint triggers.$DOC$;
