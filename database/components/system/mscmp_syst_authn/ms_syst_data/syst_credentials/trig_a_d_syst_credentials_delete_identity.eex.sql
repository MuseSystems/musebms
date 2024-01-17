CREATE OR REPLACE FUNCTION ms_syst_data.trig_a_d_syst_credentials_delete_identity()
RETURNS trigger AS
$BODY$

-- File:        trig_a_d_syst_credentials_delete_identity.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst_data/syst_credentials/trig_a_d_syst_credentials_delete_identity.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

DECLARE

BEGIN
    -- Note that currently for all credential types which expect a
    -- credential_for_identity_id value, the correct course of action here is to
    -- delete the associated identity record.  If this assumption should change,
    -- such as if we should directly associate email identities with password
    -- credentials, this logic will need to consider the credential type since
    -- emails would not be deleted in all scenarios (passwords are recoverable).

    DELETE FROM ms_syst_data.syst_identities WHERE id = old.credential_for_identity_id;

    RETURN NULL;

END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION ms_syst_data.trig_a_d_syst_credentials_delete_identity()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_data.trig_a_d_syst_credentials_delete_identity() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_data.trig_a_d_syst_credentials_delete_identity() TO <%= ms_owner %>;

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
    var_comments_config.function_name   := 'trig_a_d_syst_credentials_delete_identity';

    var_comments_config.trigger_function := TRUE;
    var_comments_config.trigger_timing   := ARRAY [ 'a' ]::text[ ];
    var_comments_config.trigger_ops      := ARRAY [ 'd' ]::text[ ];

    var_comments_config.description :=
$DOC$Deletes the syst_identities record associated with a newly deleted
syst_credentials record.

For those credential types that expect a relationship to syst_identities via the
syst_credentials.credential_for_identity_id column, the specific identifier and
credential data are closely related and updates to one or the other makes no
sense.  The correct process for updating such a pair is to delete both of the
existing identity and credential records and simply generate a new pair.
Deleting identity records achieves this goal via the constraint on the
credential_for_identity_id definition (ON DELETE CASCADE), but deleting a
credential has no automatic deletion feature thus this trigger.$DOC$;


    PERFORM ms_syst_priv.generate_comments_function( var_comments_config );

END;
$DOCUMENTATION$;
