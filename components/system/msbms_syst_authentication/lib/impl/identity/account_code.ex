# Source File: account_code.ex
# Location:    musebms/components/system/msbms_syst_authentication/lib/impl/identity/account_code.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystAuthentication.Impl.Identity.AccountCode do
  import Ecto.Query

  alias MsbmsSystAuthentication.Data
  alias MsbmsSystAuthentication.Impl
  alias MsbmsSystAuthentication.Types

  require Logger

  @behaviour MsbmsSystAuthentication.Impl.Identity

  @moduledoc false

  @default_identity_token_length 12
  @default_identity_tokens :b32c
  @default_create_validated false

  @spec create_identity(Types.access_account_id(), Types.account_identifier() | nil, Keyword.t()) ::
          {:ok, Data.SystIdentities.t()} | {:error, MsbmsSystError.t() | Exception.t()}
  def create_identity(access_account_id, account_code, opts)
      when is_binary(access_account_id) do
    opts =
      MsbmsSystUtils.resolve_options(opts,
        identity_token_length: @default_identity_token_length,
        identity_tokens: @default_identity_tokens,
        create_validated: @default_create_validated
      )

    account_code =
      account_code ||
        MsbmsSystUtils.get_random_string(opts[:identity_token_length], opts[:identity_tokens])

    identity_params = %{
      access_account_id: access_account_id,
      identity_type_name: "identity_types_sysdef_account",
      account_identifier: account_code
    }

    {:ok, Impl.Identity.Helpers.create_identity(identity_params, opts)}
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MsbmsSystError{
         code: :undefined_error,
         message: "Failure creating Account Code Identity.",
         cause: error
       }}
  end

  @spec identify_access_account(
          Types.account_identifier(),
          MsbmsSystInstanceMgr.Types.owner_id() | nil
        ) :: Data.SystIdentities.t() | nil
  def identify_access_account(account_code, owner_id) when is_binary(account_code) do
    account_code
    |> Impl.Identity.Helpers.get_identification_query(
      "identity_types_sysdef_account",
      owner_id,
      :require_unvalidated
    )
    |> MsbmsSystDatastore.one()
  end

  @spec reset_identity_for_access_account_id(Types.access_account_id(), Keyword.t()) ::
          {:ok, Data.SystIdentities.t()} | {:error, MsbmsSystError.t() | Exception.t()}
  def reset_identity_for_access_account_id(access_account_id, opts) do
    identity_type =
      MsbmsSystEnums.get_enum_item_by_name("identity_types", "identity_types_sysdef_account")

    from(i in Data.SystIdentities,
      where: i.access_account_id == ^access_account_id and i.identity_type_id == ^identity_type.id
    )
    |> MsbmsSystDatastore.one!()
    |> reset_identity(opts)
  end

  @spec reset_identity(Types.identity_id() | Data.SystIdentities.t(), Keyword.t()) ::
          {:ok, Data.SystIdentities.t()} | {:error, MsbmsSystError.t() | Exception.t()}
  def reset_identity(identity_id, opts) when is_binary(identity_id) do
    from(i in Data.SystIdentities, where: i.id == ^identity_id)
    |> MsbmsSystDatastore.one!()
    |> reset_identity(opts)
  end

  def reset_identity(%Data.SystIdentities{} = identity, opts) do
    opts = MsbmsSystUtils.resolve_options(opts, @default_account_code_params)

    result =
      MsbmsSystDatastore.transaction(fn ->
        :ok = Impl.Identity.delete_identity(identity.id)

        create_identity(identity.access_account_id, nil, opts)
      end)

    process_reset_identity_result(result)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MsbmsSystError{
         code: :undefined_error,
         message: "Failure retrieving Account Code.",
         cause: error
       }}
      }
  end

  defp process_reset_identity_result({:ok, new_identity}), do: new_identity

  defp process_reset_identity_result(error) do
    raise MsbmsSystError,
      code: :undefined_error,
      message: "Account Code reset transaction exception.",
      cause: error
  end
end
