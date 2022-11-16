# Source File: instance_type_context_test.exs
# Location:    musebms/components/system/mscmp_syst_instance/test/instance_type_context_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule InstanceTypeContextTest do
  use InstanceMgrTestCase, async: true

  import Ecto.Query

  alias MscmpSystInstance.Data

  test "Can Update Instance Type Context" do
    instance_type_context =
      from(
        itc in Data.SystInstanceTypeContexts,
        join: ac in assoc(itc, :application_context),
        where: ac.login_context,
        limit: 1
      )
      |> MscmpSystDb.one!()

    id_test_params = %{
      default_db_pool_size: instance_type_context.default_db_pool_size + 1
    }

    # Using ID for record identity

    assert {:ok, id_updated_record} =
             MscmpSystInstance.update_instance_type_context(
               instance_type_context.id,
               id_test_params
             )

    assert id_updated_record.default_db_pool_size == id_test_params.default_db_pool_size

    # Using Struct for record identity

    struct_test_params = %{
      default_db_pool_size: instance_type_context.default_db_pool_size
    }

    assert {:ok, struct_updated_record} =
             MscmpSystInstance.update_instance_type_context(
               instance_type_context,
               struct_test_params
             )

    assert struct_updated_record.default_db_pool_size == struct_test_params.default_db_pool_size
  end
end
