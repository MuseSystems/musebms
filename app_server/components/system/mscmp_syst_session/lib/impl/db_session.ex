# Source File: db_session.ex
# Location:    musebms/app_server/components/system/mscmp_syst_session/lib/impl/db_session.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystSession.Impl.DbSession do
  import Ecto.Query

  alias MscmpSystSession.Types

  @moduledoc false

  require Logger

  @default_expires_after_secs 3600

  @spec create_session(map(), non_neg_integer()) ::
          {:ok, Types.session_name()} | {:error, MscmpSystError.t()}
  def create_session(session_data, expires_after_secs) do
    session_name = Base.encode64(:crypto.strong_rand_bytes(96))

    expiration = get_expiration_date(expires_after_secs)

    new_session_params = %{
      internal_name: session_name,
      session_data: session_data,
      session_expires: expiration
    }

    new_session_params
    |> Msdata.SystSessions.insert_changeset()
    |> MscmpSystDb.insert!(returning: [:internal_name])
    |> then(&{:ok, &1.internal_name})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Unexpected failure creating Session.",
         cause: error
       }}
  end

  @spec get_session(Types.session_name(), non_neg_integer()) ::
          {:ok, Types.session_data()} | {:ok, :not_found} | {:error, MscmpSystError.t()}
  def get_session(session_name, expires_after_secs) when is_binary(session_name) do
    current_datetime = DateTime.utc_now() |> DateTime.truncate(:second)

    new_expiration = get_expiration_date(expires_after_secs)

    from(s in Msdata.SystSessions,
      update: [set: [session_expires: ^new_expiration]],
      select: s,
      where: s.internal_name == ^session_name and s.session_expires >= ^current_datetime
    )
    |> MscmpSystDb.update_all([])
    |> case do
      {0, _} ->
        {:ok, :not_found}

      {1, [result | _]} ->
        {:ok, result.session_data}

      error ->
        {:error,
         %MscmpSystError{
           code: :undefined_error,
           message: "Invalid Session search result.",
           cause: error
         }}
    end
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Unexpected failure retrieving Session.",
         cause: error
       }}
  end

  def get_session(_, _), do: {:ok, :not_found}

  @spec refresh_session_expiration(Types.session_name(), non_neg_integer()) ::
          :ok | {:ok, :not_found} | {:error, MscmpSystError.t()}
  def refresh_session_expiration(session_name, expires_after_secs) do
    current_datetime = DateTime.utc_now() |> DateTime.truncate(:second)

    new_expiration = get_expiration_date(expires_after_secs)

    from(s in Msdata.SystSessions,
      update: [set: [session_expires: ^new_expiration]],
      where: s.internal_name == ^session_name and s.session_expires >= ^current_datetime
    )
    |> MscmpSystDb.update_all([])
    |> case do
      {0, _} ->
        {:ok, :not_found}

      {1, _} ->
        :ok

      error ->
        {:error,
         %MscmpSystError{
           code: :undefined_error,
           message: "Invalid refreshing Session expiration date/time result.",
           cause: error
         }}
    end
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Unexpected failure refreshing Session expiration date/time.",
         cause: error
       }}
  end

  @spec update_session(Types.session_name(), Types.session_data(), non_neg_integer()) ::
          :ok | {:ok, :not_found} | {:error, MscmpSystError.t()}
  def update_session(session_name, session_data, expires_after_secs) do
    current_datetime = DateTime.utc_now() |> DateTime.truncate(:second)

    new_expiration = get_expiration_date(expires_after_secs)

    from(s in Msdata.SystSessions,
      update: [set: [session_data: ^session_data, session_expires: ^new_expiration]],
      where: s.internal_name == ^session_name and s.session_expires >= ^current_datetime
    )
    |> MscmpSystDb.update_all([])
    |> case do
      {0, _} ->
        {:ok, :not_found}

      {1, _} ->
        :ok

      error ->
        {:error,
         %MscmpSystError{
           code: :undefined_error,
           message: "Invalid Session update result.",
           cause: error
         }}
    end
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Unexpected failure updating Session.",
         cause: error
       }}
  end

  @spec delete_session(Types.session_name()) ::
          :ok | {:ok, :not_found} | {:error, MscmpSystError.t()}
  def delete_session(session_name) do
    from(s in Msdata.SystSessions, where: s.internal_name == ^session_name)
    |> MscmpSystDb.delete_all()
    |> case do
      {0, _} ->
        {:ok, :not_found}

      {1, _} ->
        :ok

      error ->
        {:error,
         %MscmpSystError{
           code: :undefined_error,
           message: "Failure deleting Session.",
           cause: error
         }}
    end
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Unexpected failure deleting Session.",
         cause: error
       }}
  end

  # Note that we can't readily test purging in the Unit Tests suite.  We have
  # sufficient control to test in the Integration Tests suite.

  @spec purge_expired_sessions() :: :ok | {:error, MscmpSystError.t()}
  def purge_expired_sessions do
    current_datetime = DateTime.utc_now() |> DateTime.truncate(:second)

    from(s in Msdata.SystSessions, where: s.session_expires < ^current_datetime)
    |> MscmpSystDb.delete_all()
    |> case do
      {_, _} ->
        :ok

      error ->
        {:error,
         %MscmpSystError{
           code: :undefined_error,
           message: "Failure purging expired Sessions.",
           cause: error
         }}
    end
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Unexpected failure purging expired Sessions.",
         cause: error
       }}
  end

  defp get_expiration_date(expires_after_secs) do
    DateTime.utc_now()
    |> DateTime.add(expires_after_secs)
    |> DateTime.truncate(:second)
  end
end
