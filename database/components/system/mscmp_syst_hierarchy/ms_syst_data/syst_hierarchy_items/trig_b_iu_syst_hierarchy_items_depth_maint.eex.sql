CREATE OR REPLACE FUNCTION ms_syst_data.trig_b_iu_syst_hierarchy_items_depth_maint()
RETURNS trigger AS
$BODY$

-- File:        trig_b_iu_syst_hierarchy_items_depth_maint.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_hierarchy/ms_syst_data/syst_hierarchy_items/trig_b_iu_syst_hierarchy_items_depth_maint.eex.sql
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

    CASE
        WHEN tg_op = 'INSERT' AND new.hierarchy_depth IS NULL THEN

            new.hierarchy_depth :=
                coalesce( ( SELECT max( hierarchy_depth ) + 1
                            FROM ms_syst_data.syst_hierarchy_items
                            WHERE hierarchy_id = new.hierarchy_id ), 1 );

        WHEN
            exists( SELECT TRUE
                    FROM ms_syst_data.syst_hierarchy_items
                    WHERE hierarchy_id   = new.hierarchy_id
                      AND hierarchy_depth = new.hierarchy_depth )
        THEN

            UPDATE ms_syst_data.syst_hierarchy_items
            SET hierarchy_depth = hierarchy_depth + 1
            WHERE hierarchy_id   = new.hierarchy_id
              AND hierarchy_depth = new.hierarchy_depth;

        ELSE
            NULL;
    END CASE;

    RETURN new;

END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION ms_syst_data.trig_b_iu_syst_hierarchy_items_depth_maint()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_data.trig_b_iu_syst_hierarchy_items_depth_maint() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_data.trig_b_iu_syst_hierarchy_items_depth_maint() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst_data.trig_b_iu_syst_hierarchy_items_depth_maint() IS
$DOC$Manages the `hierarchy_depth` column value.  Depending on the passed data, this
trigger will perform different actions.

When a new Hierarchy Item record is inserted without specifying a
`hierarchy_depth` value, this trigger will assign it the next highest
`hierarchy_depth` value based on the existing Hierarchy Item records assigned
to the Hierarchy, or 1 if there are no existing Hierarchy Item records
assigned to the Hierarchy.

When a new Hierarchy Item record is inserted specifying an explicit
`hierarchy_depth` value, we assume that insertion is done with knowing intent
and we will not change the inserted value in this trigger.  `hierarchy_depth`
values must be unique for any members of a single Hierarchy.  In the case where
the inserted record's explicit `hierarchy_depth` value does not collide with a
pre-existing value, we simply take that value as-is.  When there is a collision,
we take an "insert before" approach: the pre-existing record with which the new
record collides has its `hierarchy_depth` value increased by 1; if this updated
value in turn collides with another pre-existing record in the Hierarchy, we
update this next record by incrementing its value by 1.  This continues until
all collisions in the Hierarchy are resolved to be unique.

Updated records follow the same patterns as inserted records, except that we do
not expect that the update will attempt to NULL the `hierarchy_depth` value.  If
an update would leave a gap, we do not try to renumber the `hierarchy_depth`
values meaning that the `hierarchy_depth` sequence within any Hierarchy may
indeed include gaps: we only attempt to keep overall ordering consistent and we
do not attempt to achieve a gapless numbering scheme.$DOC$;
