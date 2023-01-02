-- File:        syst_access_account_perm_role_assigns.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_mcp_perms/ms_syst/api_views/syst_access_account_perm_role_assigns/syst_access_account_perm_role_assigns.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE VIEW ms_syst.syst_access_account_perm_role_assigns AS
    SELECT
          id
        , access_account_id
        , perm_role_id
        , diag_timestamp_created
        , diag_role_created
        , diag_timestamp_modified
        , diag_wallclock_modified
        , diag_role_modified
        , diag_row_version
        , diag_update_count
    FROM ms_syst_data.syst_access_account_perm_role_assigns;

ALTER VIEW ms_syst.syst_access_account_perm_role_assigns OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_access_account_perm_role_assigns FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_access_account_perm_role_assigns
    INSTEAD OF INSERT ON ms_syst.syst_access_account_perm_role_assigns
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_access_account_perm_role_assigns();

CREATE TRIGGER a50_trig_i_u_syst_access_account_perm_role_assigns
    INSTEAD OF UPDATE ON ms_syst.syst_access_account_perm_role_assigns
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_access_account_perm_role_assigns();

CREATE TRIGGER a50_trig_i_d_syst_access_account_perm_role_assigns
    INSTEAD OF DELETE ON ms_syst.syst_access_account_perm_role_assigns
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_access_account_perm_role_assigns();

COMMENT ON
    VIEW ms_syst.syst_access_account_perm_role_assigns IS
$DOC$Assigns Permission Roles to Access Accounts providing an MCP authentication
mechanism.

This API View allows the application to read and maintain the data according to
well defined application business rules.  Using this API view for updates to
data is the preferred method of data maintenance in the course of normal usage.

Only user maintainable values may be maintained via this API.  System created or
maintained data is not maintainable via this view.  Attempts at invalid data
maintenance via this API may result in the invalid changes being ignored or may
raise an exception.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_account_perm_role_assigns.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_account_perm_role_assigns.access_account_id IS
$DOC$References the Access Account to which the Permission Role is being assigned.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_account_perm_role_assigns.perm_role_id IS
$DOC$A reference to the Permission Role being assigned to the Access Account.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_account_perm_role_assigns.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_account_perm_role_assigns.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_account_perm_role_assigns.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_account_perm_role_assigns.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_account_perm_role_assigns.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_account_perm_role_assigns.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_account_perm_role_assigns.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;