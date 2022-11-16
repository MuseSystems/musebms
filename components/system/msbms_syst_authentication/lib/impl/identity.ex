# Source File: identity.ex
# Location:    musebms/components/system/msbms_syst_authentication/lib/impl/identity.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystAuthentication.Impl.Identity do
  import Ecto.Query

  alias MsbmsSystAuthentication.Data
  alias MsbmsSystAuthentication.Impl.Identity.Helpers
  alias MsbmsSystAuthentication.Types

  require Logger

  @moduledoc false

  # Setup callbacks for Identity type specific calls

  @callback create_identity(Types.access_account_id(), Types.account_identifier(), Keyword.t()) ::
              {:ok, Data.SystIdentities.t()} | {:error, MscmpSystError.t() | Exception.t()}

  @callback identify_access_account(
              Types.account_identifier(),
              MscmpSystInstance.Types.owner_id() | nil
            ) :: Data.SystIdentities.t() | nil

  # General Identity functionality

  @spec set_identity_expiration(Types.identity_id() | Data.SystIdentities.t(), DateTime.t()) ::
          {:ok, Data.SystIdentities.t()} | {:error, MscmpSystError.t()}
  def set_identity_expiration(identity_id, %DateTime{} = expires_date)
      when is_binary(identity_id) do
    identity_id
    |> get_identity_record()
    |> set_identity_expiration(expires_date)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure setting Identity expiration by ID.",
          cause: error
        }
      }
  end

  def set_identity_expiration(%Data.SystIdentities{} = identity, %DateTime{} = expires_date) do
    {:ok, Helpers.update_record(identity, %{identity_expires: expires_date})}
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure setting Identity expiration.",
          cause: error
        }
      }
  end

  @spec clear_identity_expiration(Types.identity_id() | Data.SystIdentities.t()) ::
          {:ok, Data.SystIdentities.t()} | {:error, MscmpSystError.t()}

  def clear_identity_expiration(identity_id) when is_binary(identity_id) do
    identity_id
    |> get_identity_record()
    |> clear_identity_expiration()
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure clearing Identity expiration by ID.",
          cause: error
        }
      }
  end

  def clear_identity_expiration(%Data.SystIdentities{} = identity) do
    {:ok, Helpers.update_record(identity, %{identity_expires: nil})}
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure clearing Identity expiration.",
          cause: error
        }
      }
  end

  @spec identity_expired?(Types.identity_id() | Data.SystIdentities.t()) ::
          {:ok, boolean()} | {:error, MscmpSystError.t()}
  def identity_expired?(identity) when is_binary(identity) do
    from(i in Data.SystIdentities,
      where: i.id == ^identity,
      select: struct(i, [:identity_expires])
    )
    |> MscmpSystDb.one!()
    |> identity_expired?()
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure testing identity expiration by ID.",
          cause: error
        }
      }
  end

  def identity_expired?(%Data.SystIdentities{} = identity) do
    expired =
      if identity.identity_expires == nil,
        do: false,
        else: DateTime.compare(DateTime.utc_now(), identity.identity_expires) == :gt

    {:ok, expired}
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure testing identity expiration.",
          cause: error
        }
      }
  end

  @spec identity_validated?(Types.identity_id() | Data.SystIdentities.t()) ::
          {:ok, boolean()} | {:error, MscmpSystError.t()}
  def identity_validated?(identity) when is_binary(identity) do
    from(i in Data.SystIdentities,
      where: i.id == ^identity,
      select: struct(i, [:validated])
    )
    |> MscmpSystDb.one!()
    |> identity_validated?()
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure testing identity validated by ID.",
          cause: error
        }
      }
  end

  def identity_validated?(%Data.SystIdentities{validated: validated}) when not is_nil(validated),
    do: {:ok, true}

  def identity_validated?(%Data.SystIdentities{}), do: {:ok, false}

  @spec delete_identity(Types.identity_id() | Data.SystIdentities.t(), Types.identity_type_name()) ::
          :deleted | :not_found
  def delete_identity(identity_id, identity_type_name)
      when is_binary(identity_id) and is_binary(identity_type_name) do
    from(i in Data.SystIdentities,
      join: ei in assoc(i, :identity_type),
      where: i.id == ^identity_id and ei.internal_name == ^identity_type_name
    )
    |> MscmpSystDb.delete_all()
    |> case do
      {0, _} ->
        :not_found

      {1, _} ->
        :deleted

      error ->
        raise MscmpSystError,
          code: :undefined_error,
          message: "Failure deleting Identity.",
          cause: error
    end
  end

  def delete_identity(%Data.SystIdentities{} = identity, identity_type_name),
    do: delete_identity(identity.id, identity_type_name)

  @spec get_identity_record(Types.identity_id()) :: Data.SystIdentities.t()
  def get_identity_record(identity_id) when is_binary(identity_id) do
    from(i in Data.SystIdentities, where: i.id == ^identity_id)
    |> MscmpSystDb.one!()
  end
end
