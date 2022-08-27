# Source File: access_account_instance_assoc_test.exs
# Location:    musebms/components/system/msbms_syst_authentication/test/access_account_instance_assoc_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule AccessAccountInstanceAssocTest do
  use AuthenticationTestCase, async: true

  import Ecto.Query

  alias MsbmsSystAuthentication.Data

  test "Can invite Access Account to Instance Immediate Acceptance" do
    {:ok, access_account} =
      MsbmsSystAuthentication.get_access_account_by_name("invite_to_instance_test_accnt")

    instance_id =
      from(
        i in MsbmsSystInstanceMgr.Data.SystInstances,
        join: o in assoc(i, :owner),
        join: is in assoc(i, :instance_state),
        where:
          o.internal_name == "owner1" and is.internal_name == "instance_states_sysdef_active",
        select: i.id,
        limit: 1
      )
      |> MsbmsSystDatastore.one!()

    credential_type =
      MsbmsSystEnums.get_enum_item_by_name(
        "credential_types",
        "credential_types_sysdef_token_api"
      )

    assert {:ok, access_account_instance_assoc} =
             MsbmsSystAuthentication.invite_access_account_to_instance(
               access_account.id,
               instance_id,
               credential_type.id,
               create_accepted: true
             )
             |> IO.inspect()
  end
end
