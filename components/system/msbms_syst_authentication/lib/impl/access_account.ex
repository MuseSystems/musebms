# Source File: access_account.ex
# Location:    musebms/components/system/msbms_syst_authentication/lib/impl/access_account.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystAuthentication.Impl.AccessAccount do
  import Ecto.Query
  import MsbmsSystUtils

  alias MsbmsSystAuthentication.Data
  alias MsbmsSystAuthentication.Types

  require Logger

  @moduledoc false

  @spec get_access_account_id_by_name(Types.access_account_name()) ::
          {:ok, Types.access_account_id()} | {:error, MsbmsSystError.t()}
  def get_access_account_id_by_name(access_account_name) when is_binary(access_account_name) do
    from(aa in Data.SystAccessAccounts,
      select: aa.id,
      where: aa.internal_name == ^access_account_name
    )
    |> MsbmsSystDatastore.one!()
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure retrieving Access Account ID by internal name.",
          cause: error
        }
      }
  end
end
