CREATE OR REPLACE FUNCTION ms_syst.trig_i_u_syst_groups()
RETURNS trigger AS
$BODY$

-- File:        trig_i_u_syst_groups.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_groups/ms_syst/api_views/syst_groups/trig_i_u_syst_groups.eex.sql
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
    -- TODO: Decide if we really want the parent_group_id and group_type_item_id
    --       columns to be updatable.  My gut sense is that we probably don't
    --       because there are cases where that would be harmful, such as when
    --       groups are used as the basis of aggregated data.

    IF
        old.syst_defined AND NOT old.user_maintainable AND
            (new.internal_name         != old.new.internal_name OR
                new.display_name       != old.new.display_name OR
                new.external_name      != old.new.external_name OR
                new.parent_group_id    != old.new.parent_group_id OR
                new.group_type_item_id != old.new.group_type_item_id)
    THEN

        RAISE EXCEPTION
            USING
                MESSAGE = 'The requested data update included changes to fields disallowed ' ||
                          'by the business rules applying to non-user maintainable ' ||
                          'System Defined records.  The requested change cannot ' ||
                          'be made using this API view.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst'
                            ,p_proc_name      => 'trig_i_u_syst_groups'
                            ,p_exception_name => 'invalid_api_view_call'
                            ,p_errcode        => 'PM008'
                            ,p_param_data     => to_jsonb(new)
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

    UPDATE ms_syst_data.syst_groups
    SET
        internal_name      = new.internal_name
      , display_name       = new.display_name
      , external_name      = new.external_name
      , parent_group_id    = new.parent_group_id
      , group_type_item_id = new.group_type_item_id
      , user_description   = new.user_description
    WHERE id = new.id
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql 
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_u_syst_groups()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_groups() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_groups() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_u_syst_groups() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_groups API View for UPDATE operations.$DOC$;
