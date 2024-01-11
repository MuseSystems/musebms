-- File:        syst_perm_functional_types.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_perms/ms_syst_data/syst_perm_functional_types/syst_perm_functional_types.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

-- TODO: Why is this table here?  Isn't this just an Enumeration?

CREATE TABLE ms_syst_data.syst_perm_functional_types
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v7( )
        CONSTRAINT syst_perm_functional_types_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_perm_functional_types_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT syst_perm_functional_types_display_name_udx UNIQUE
    ,syst_description
        text
        NOT NULL
    ,user_description
        text
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
);

ALTER TABLE ms_syst_data.syst_perm_functional_types OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_perm_functional_types FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_perm_functional_types TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_perm_functional_types
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

DO
$DOCUMENTATION$
DECLARE
    -- Table
    var_comments_config ms_syst_priv.comments_config_table;

BEGIN

    --
    -- Table Config
    --

    var_comments_config.table_schema := 'ms_syst_data';
    var_comments_config.table_name   := 'syst_perm_functional_types';

    var_comments_config.description :=
$DOC$Defines application specific areas of applicability to which Permissions and
Permission Roles are assigned.

When an application defines varying areas of business controls, Permission
Functional Types can be used to group Permissions into their specific areas and
limit usage and role assignment by area.  Consider an application which supports
multiple warehouses containing inventory.  The application may define globally
applicable Permissions such as the ability to log into the application, but may
allow employees to be granted varying degrees of Permission to each individual
warehouse's inventory management features.  In this case there would be "Global"
Permission Functional Type containing the log in Permission and a "Warehouse"
Permission Functional Type for those Permissions and Permission Roles which can
vary warehouse by warehouse.$DOC$;
    var_comments_config.general_usage :=
$DOC$Both Permissions and Permission Roles must share a Permission Functional Type
since the Permission Functional Type establishes the context of applicability
for both.$DOC$;

    PERFORM ms_syst_priv.generate_comments_table( var_comments_config );

END;
$DOCUMENTATION$;
