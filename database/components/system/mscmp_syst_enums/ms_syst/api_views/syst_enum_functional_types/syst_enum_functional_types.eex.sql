-- File:        syst_enum_functional_types.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_enums/ms_syst/api_views/syst_enum_functional_types/syst_enum_functional_types.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE VIEW ms_syst.syst_enum_functional_types AS
    SELECT
        seft.id
      , seft.internal_name
      , seft.display_name
      , seft.external_name
      , se.syst_defined
      , seft.enum_id
      , seft.syst_description
      , seft.user_description
      , seft.diag_timestamp_created
      , seft.diag_role_created
      , seft.diag_timestamp_modified
      , seft.diag_wallclock_modified
      , seft.diag_role_modified
      , seft.diag_row_version
      , seft.diag_update_count
    FROM ms_syst_data.syst_enum_functional_types seft
        JOIN ms_syst_data.syst_enums se
            ON se.id = seft.enum_id;

ALTER VIEW ms_syst.syst_enum_functional_types OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_enum_functional_types FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_enum_functional_types
    INSTEAD OF INSERT ON ms_syst.syst_enum_functional_types
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_enum_functional_types();

CREATE TRIGGER a50_trig_i_u_syst_enum_functional_types
    INSTEAD OF UPDATE ON ms_syst.syst_enum_functional_types
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_enum_functional_types();

CREATE TRIGGER a50_trig_i_d_syst_enum_functional_types
    INSTEAD OF DELETE ON ms_syst.syst_enum_functional_types
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_enum_functional_types();

DO
$DOCUMENTATION$
DECLARE
    var_view_config ms_syst_priv.comments_config_apiview;

    var_syst_defined ms_syst_priv.comments_config_apiview_column;
    var_enum_id      ms_syst_priv.comments_config_apiview_column;

BEGIN

    var_view_config.table_schema := 'ms_syst_data';
    var_view_config.table_name   := 'syst_enum_functional_types';
    var_view_config.view_schema  := 'ms_syst';
    var_view_config.view_name    := 'syst_enum_functional_types';
    var_view_config.syst_records := TRUE;
    var_view_config.syst_update  := TRUE;
    var_view_config.syst_delete  := FALSE;

    var_syst_defined.column_name      := 'syst_defined';
    var_syst_defined.syst_update_mode := 'never';
    var_syst_defined.user_insert      := FALSE;
    var_syst_defined.user_update      := FALSE;

    var_syst_defined.override_description :=
$DOC$If true, this value indicates that the functional type is considered to be
system defined and a part of the application.$DOC$;

    var_syst_defined.supplemental :=
$DOC$This column is not part of the Functional Type underlying data and is a
reflection of the Functional Type's parent enumeration since the parent
determines if the functional type is  considered system defined.  If false, the
assumption is that the Functional Type ` is user defined and supports custom
user functionality.

See the documentation for ms_syst.syst_enums.syst_defined for a more complete
complete description.$DOC$;

    var_enum_id.column_name      := 'enum_id';
    var_enum_id.syst_update_mode := 'never';
    var_enum_id.user_update      := FALSE;

    var_view_config.columns :=
        ARRAY [
              var_syst_defined
            , var_enum_id
            ]::ms_syst_priv.comments_config_apiview_column[];

    PERFORM ms_syst_priv.generate_comments_apiview( var_view_config );

END;
$DOCUMENTATION$;
