-- File:        enum_fiscal_year_types.eex.sql
-- Location:    musebms/database/components/application/mscmp_acc_calendar/seed_data/enum_fiscal_year_types.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

DO
$INIT_ENUM$
BEGIN

CALL
    ms_syst_priv.initialize_enum(
        p_enum_def => $INIT_ENUM_FISCAL_YEAR_TYPES$
        {
          "internal_name": "fiscal_year_types",
          "display_name": "Fiscal Year Types",
          "syst_description": "Enumerates the different supported cadences of periods for fiscal years.",
          "syst_defined": true,
          "user_maintainable": true,
          "default_syst_options": null,
          "default_user_options": null,
          "functional_types": [],
          "enum_items": []
        }
            $INIT_ENUM_FISCAL_YEAR_TYPES$::jsonb);

END;
$INIT_ENUM$;
