-- File:        initialize_enum_fiscal_period_states.eex.sql
-- Location:    database\app_msbms_instance\mod_accounting\seed_data\initialize_enum_fiscal_period_states.eex.sql
-- Project:     Muse Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

DO
$INIT_ENUM$
BEGIN

PERFORM
    msbms_syst_priv.initialize_enum(
        p_enum_def => $INIT_ENUM_FISCAL_PERIOD_STATES$
        {
          "internal_name": "fiscal_period_states",
          "display_name": "Fiscal Period States",
          "syst_description": "Life-cycle management stages for fiscal period records.",
          "feature_internal_name": "instance_accounting_supporting_fiscal_calendar_enumerations",
          "syst_defined": true,
          "user_maintainable": true,
          "default_syst_options": null,
          "default_user_options": null,
          "functional_types": [],
          "enum_values": []
        }
            $INIT_ENUM_FISCAL_PERIOD_STATES$::jsonb);

END;
$INIT_ENUM$;
