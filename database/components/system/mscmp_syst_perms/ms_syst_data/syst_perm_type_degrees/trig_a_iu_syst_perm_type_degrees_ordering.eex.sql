CREATE OR REPLACE FUNCTION ms_syst_data.trig_a_iu_syst_perm_type_degrees_ordering()
RETURNS trigger AS
$BODY$

-- File:        trig_a_iu_syst_perm_type_degrees_ordering.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_perms/ms_syst_data/syst_perm_type_degrees/trig_a_iu_syst_perm_type_degrees_ordering.eex.sql
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

    UPDATE ms_syst_data.syst_perm_type_degrees
    SET ordering = ordering + 1
    WHERE perm_type_id = new.perm_type_id AND ordering = new.ordering AND id != new.id;

    RETURN NULL;

END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION ms_syst_data.trig_a_iu_syst_perm_type_degrees_ordering()
    OWNER TO <%= msbms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_data.trig_a_iu_syst_perm_type_degrees_ordering() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_data.trig_a_iu_syst_perm_type_degrees_ordering() TO <%= msbms_owner %>;

COMMENT ON FUNCTION ms_syst_data.trig_a_iu_syst_perm_type_degrees_ordering() IS
$DOC$Automatically maintains the ordering of syst_perm_type_degrees records in cases
where the ordering column value collides with an existing syst_perm_type_degrees
record sharing the same parent syst_perm_types record.  On INSERT or UPDATE when
such an syst_perm_type_degrees.ordering column collision is found, the system
will treat the operation as an "insert before" operation.  This means that the
newly inserted/updated record will have the requested ordering value and the
existing record with a colliding value will have its ordering value incremented
by one.  This also means that the newly inserted/updated record is considered to
have lesser authority relative the record it collided with.  Finally, the
reordering will cascade through other syst_perm_type_degrees records belonging
to the same parent syst_perm_types record using the same rule described above
until all records belonging to the syst_perm_types parent record have unique
ordering amongst their sibling records.$DOC$;
