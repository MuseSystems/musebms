# Source File: disallowed_passwords.ex
# Location:    musebms/components/system/msbms_syst_authentication/lib/impl/disallowed_passwords.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystAuthentication.Impl.DisallowedPasswords do
  import Ecto.Query

  alias MsbmsSystAuthentication.Data
  alias MsbmsSystAuthentication.Impl
  alias MsbmsSystAuthentication.Types

  require Logger

  @moduledoc false

  @spec add_disallowed_password(Types.credential()) :: :ok | {:error, MsbmsSystError.t()}
  def add_disallowed_password(password) when is_binary(password) do
    password
    |> Impl.Hash.weak_hash()
    |> Data.SystDisallowedPasswords.insert_changeset()
    |> MsbmsSystDatastore.insert!()

    :ok
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure adding Disallowed Password.",
          cause: error
        }
      }
  end

  @spec password_disallowed(Types.credential()) ::
          {:ok, boolean()} | {:error, MsbmsSystError.t()}
  def password_disallowed(password) when is_binary(password) do
    pwd_hash = Impl.Hash.weak_hash(password)

    from(dp in Data.SystDisallowedPasswords, where: dp.password_hash == ^pwd_hash)
    |> MsbmsSystDatastore.exists?()
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure testing if password is disallowed.",
          cause: error
        }
      }
  end

  @spec delete_disallowed_password(Types.credential()) ::
          {:ok, :deleted | :no_record} | {:error, MsbmsSystError.t()}
  def delete_disallowed_password(password) when is_binary(password) do
    pwd_hash = Impl.Hash.weak_hash(password)

    from(dp in Data.SystDisallowedPasswords, where: dp.password_hash == ^pwd_hash)
    |> MsbmsSystDatastore.delete_all()
    |> case do
      {0, _} ->
        {:ok, :no_record}

      {1, _} ->
        {:ok, :deleted}

      error ->
        raise MsbmsSystError,
          code: :undefined_error,
          message: "Unexpected result from delete of disallowed password.",
          cause: error
    end
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure deleting Disallowed Password.",
          cause: error
        }
      }
  end
end
