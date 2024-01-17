CREATE OR REPLACE FUNCTION ms_syst_data.trig_a_iu_syst_global_network_rule_ordering()
RETURNS trigger AS
$BODY$

-- File:        trig_a_iu_syst_global_network_rule_ordering.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst_data/syst_global_network_rules/trig_a_iu_syst_global_network_rule_ordering.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

BEGIN

    UPDATE ms_syst_data.syst_global_network_rules
    SET ordering = ordering + 1
    WHERE ordering = new.ordering AND id != new.id;

    RETURN null;

END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION ms_syst_data.trig_a_iu_syst_global_network_rule_ordering()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_data.trig_a_iu_syst_global_network_rule_ordering() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_data.trig_a_iu_syst_global_network_rule_ordering() TO <%= ms_owner %>;

DO
$DOCUMENTATION$
DECLARE
    -- Function
    var_comments_config ms_syst_priv.comments_config_function;

BEGIN

    --
    -- Function Config
    --

    var_comments_config.function_schema := 'ms_syst_data';
    var_comments_config.function_name   := 'trig_a_iu_syst_global_network_rule_ordering';

    var_comments_config.trigger_function := TRUE;
    var_comments_config.trigger_timing   := ARRAY [ 'a' ]::text[ ];
    var_comments_config.trigger_ops      := ARRAY [ 'i', 'u' ]::text[ ];

    var_comments_config.description :=
$DOC$Ensures that the ordering of network rules is maintained and that ordering
values are not duplicated.$DOC$;

    PERFORM ms_syst_priv.generate_comments_function( var_comments_config );

END;
$DOCUMENTATION$;
