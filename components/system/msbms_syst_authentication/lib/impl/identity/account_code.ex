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
  @default_create_validated true

  @spec create_identity(Types.access_account_id(), Types.account_identifier() | nil, Keyword.t()) ::
          {:ok, Data.SystIdentities.t()} | {:error, MscmpSystError.t() | Exception.t()}
  def create_identity(access_account_id, account_code, opts)
      when is_binary(access_account_id) do
    opts =
      MscmpSystUtils.resolve_options(opts,
        identity_token_length: @default_identity_token_length,
        identity_tokens: @default_identity_tokens,
        create_validated: @default_create_validated
      )

    account_code =
      account_code ||
        MscmpSystUtils.get_random_string(opts[:identity_token_length], opts[:identity_tokens])

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
       %MscmpSystError{
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
    |> Impl.Identity.Helpers.get_identification_query("identity_types_sysdef_account", owner_id)
    |> MscmpSystDb.one()
  end

  @spec reset_identity_for_access_account_id(Types.access_account_id(), Keyword.t()) ::
          {:ok, Data.SystIdentities.t()} | {:error, MscmpSystError.t() | Exception.t()}
  def reset_identity_for_access_account_id(access_account_id, opts) do
    reset_func = fn ->
      from(i in Data.SystIdentities,
        join: ei in assoc(i, :identity_type),
        where:
          i.access_account_id == ^access_account_id and
            ei.internal_name == "identity_types_sysdef_account",
        select: i.id
      )
      |> MscmpSystDb.one()
      |> maybe_delete_identity()
      |> maybe_create_identity_after_delete(access_account_id, opts)
      |> case do
        {:ok, new_identity} ->
          new_identity

        error ->
          MscmpSystDb.rollback(%MscmpSystError{
            code: :undefined_error,
            message: "Failure resetting Account Code Identity.",
            cause: error
          })
      end
    end

    MscmpSystDb.transaction(reset_func)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Exception while resetting Account Code Identity.",
         cause: error
       }}
  end

  defp maybe_delete_identity(identity_id) when is_binary(identity_id),
    do: Impl.Identity.delete_identity(identity_id, "identity_types_sysdef_account")

  defp maybe_delete_identity(nil = _identity_id), do: :not_found

  defp maybe_create_identity_after_delete(delete_result, access_account_id, opts)
       when delete_result in [:deleted, :not_found],
       do: create_identity(access_account_id, opts[:account_code], opts)

  defp maybe_create_identity_after_delete(delete_result, _access_account_id, _opts) do
    raise MscmpSystError,
      code: :undefined_error,
      message: "Unexpected Account Code Identity deletion result.",
      cause: delete_result
  end

  @spec get_account_code_by_access_account_id(Types.access_account_id()) ::
          {:ok, Data.SystIdentities.t() | :not_found} | {:error, MscmpSystError.t()}
  def get_account_code_by_access_account_id(access_account_id)
      when is_binary(access_account_id) do
    from(i in Data.SystIdentities,
      join: ei in assoc(i, :identity_type),
      where:
        i.access_account_id == ^access_account_id and
          ei.internal_name == "identity_types_sysdef_account"
    )
    |> MscmpSystDb.one()
    |> process_account_code_lookup_result()
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure retrieving Account Code.",
         cause: error
       }}
  end

  defp process_account_code_lookup_result(%Data.SystIdentities{} = identity),
    do: {:ok, identity}

  defp process_account_code_lookup_result(nil), do: {:ok, :not_found}

  defp process_account_code_lookup_result(error) do
    raise MscmpSystError,
      code: :undefined_error,
      message: "Exception retrieving Account Code.",
      cause: error
  end
end
