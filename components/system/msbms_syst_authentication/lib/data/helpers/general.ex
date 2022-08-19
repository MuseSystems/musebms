# Source File: general.ex
# Location:    musebms/components/system/msbms_syst_authentication/lib/data/helpers/general.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystAuthentication.Data.Helpers.General do
  @moduledoc false

  alias MsbmsSystAuthentication.Impl

  def resolve_access_account_id(%{access_account_name: access_account_name} = change_params)
      when is_binary(access_account_name) do
    {:ok, access_account_id} =
      Impl.AccessAccount.get_access_account_id_by_name(access_account_name)

    Map.put(change_params, :access_account_od, access_account_id)
  end
end
