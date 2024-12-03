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
  @moduledoc false

  import Ecto.Query

  alias MscmpSystError.Types, as: ErrorTypes
  alias MscmpSystSession.Types

  ##############################################################################
  #
  # generate_session_name
  #
  #

  @spec generate_session_name(Keyword.t()) :: Types.session_name()
  def generate_session_name(opts),
    do: Msutils.String.get_random_string(opts[:session_name_length], opts[:session_name_tokens])

  ##############################################################################
  #
  # create_session
  #
  #

  @spec create_session(map(), Keyword.t()) ::
          {:ok, Types.session_name()} | ErrorTypes.parsable_error()
  def create_session(session_data, opts) do
    # TODO: Think about the public API call in this private module context.
    #       Right now I want the defaults set at the API, but now I'm tying the
    #       private implementation to the public API which may not be good.
    #       However, the de-facto alternative would be to have two statements of
    #       the defaults... one here and one at the API level and that's not
    #       good either.

    session_name = opts[:session_name] || MscmpSystSession.generate_session_name()
    expiration = get_expiration_date(opts[:expires_after])

    new_session_params = %{
      internal_name: session_name,
      session_data: session_data,
      session_expires: expiration
    }

    new_session_params
    |> Msdata.SystSessions.insert_changeset()
    |> MscmpSystDb.insert(returning: [:internal_name])
    |> case do
      {:ok, result} -> {:ok, result.internal_name}
      error -> {:error, error}
    end
  rescue
    error in Postgrex.Error -> {:error, MscmpSystDb.get_pg_exception(error)}
    error -> reraise(error, __STACKTRACE__)
  end

  ##############################################################################
  #
  # get_session
  #
  #

  @spec get_session(Types.session_name(), Keyword.t()) ::
          {:ok, Types.session_data()} | ErrorTypes.parsable_error()
  def get_session(session_name, opts) when is_binary(session_name) do
    current_datetime = DateTime.utc_now() |> DateTime.truncate(:second)

    new_expiration = get_expiration_date(opts[:expires_after])

    from(s in Msdata.SystSessions,
      update: [set: [session_expires: ^new_expiration]],
      select: s,
      where: s.internal_name == ^session_name and s.session_expires >= ^current_datetime
    )
    |> MscmpSystDb.update_all([])
    |> case do
      {0, _} ->
        {:error, {:not_found, "The requested session was not found."}}

      {1, [result | _]} ->
        {:ok, result.session_data}
    end
  rescue
    error in Postgrex.Error -> {:error, MscmpSystDb.get_pg_exception(error)}
    error -> reraise(error, __STACKTRACE__)
  end

  def get_session(_, _), do: raise(ArgumentError, "Invalid session request.")

  ##############################################################################
  #
  # refresh_session_expiration
  #
  #

  @spec refresh_session_expiration(Types.session_name(), Keyword.t()) ::
          :ok | ErrorTypes.parsable_error()
  def refresh_session_expiration(session_name, opts) do
    current_datetime = DateTime.utc_now() |> DateTime.truncate(:second)

    new_expiration = get_expiration_date(opts[:expires_after])

    from(s in Msdata.SystSessions,
      update: [set: [session_expires: ^new_expiration]],
      where: s.internal_name == ^session_name and s.session_expires >= ^current_datetime
    )
    |> MscmpSystDb.update_all([])
    |> case do
      {1, _} ->
        :ok

      {0, _} ->
        {:error, {:not_found, "The requested session was not found and could not be refreshed."}}
    end
  rescue
    error in Postgrex.Error -> {:error, MscmpSystDb.get_pg_exception(error)}
    error -> reraise(error, __STACKTRACE__)
  end

  ##############################################################################
  #
  # update_session
  #
  #

  @spec update_session(Types.session_name(), Types.session_data(), Keyword.t()) ::
          :ok | ErrorTypes.parsable_error()
  def update_session(session_name, session_data, opts) do
    current_datetime = DateTime.utc_now() |> DateTime.truncate(:second)

    new_expiration = get_expiration_date(opts[:expires_after])

    from(s in Msdata.SystSessions,
      update: [set: [session_data: ^session_data, session_expires: ^new_expiration]],
      where: s.internal_name == ^session_name and s.session_expires >= ^current_datetime
    )
    |> MscmpSystDb.update_all([])
    |> case do
      {1, _} ->
        :ok

      {0, _} ->
        {:error, {:not_found, "The requested session was not found and could not be updated."}}
    end
  rescue
    error in Postgrex.Error -> {:error, MscmpSystDb.get_pg_exception(error)}
    error -> reraise(error, __STACKTRACE__)
  end

  ##############################################################################
  #
  # delete_session
  #
  #

  @spec delete_session(Types.session_name()) ::
          :ok | ErrorTypes.parsable_error()
  def delete_session(session_name) do
    from(s in Msdata.SystSessions, where: s.internal_name == ^session_name)
    |> MscmpSystDb.delete_all()
    |> case do
      {1, _} ->
        :ok

      {0, _} ->
        {:error, {:not_found, "The requested session was not found and could not be deleted."}}
    end
  rescue
    error in Postgrex.Error -> {:error, MscmpSystDb.get_pg_exception(error)}
    error -> reraise(error, __STACKTRACE__)
  end

  ##############################################################################
  #
  # purge_expired_sessions
  #
  #

  # Note that we can't readily test purging in the Unit Tests suite.  We have
  # sufficient control to test in the Integration Tests suite.

  @spec purge_expired_sessions(Keyword.t()) :: :ok | ErrorTypes.parsable_error()
  def purge_expired_sessions(opts) do
    current_datetime = DateTime.utc_now() |> DateTime.truncate(:second)
    db_timeout_ms = opts[:db_timeout] * 1000

    {_, _} =
      from(s in Msdata.SystSessions, where: s.session_expires < ^current_datetime)
      |> MscmpSystDb.delete_all(timeout: db_timeout_ms)

    :ok
  rescue
    error in Postgrex.Error -> {:error, MscmpSystDb.get_pg_exception(error)}
    error -> reraise(error, __STACKTRACE__)
  end

  defp get_expiration_date(expires_after) do
    DateTime.utc_now()
    |> DateTime.add(expires_after)
    |> DateTime.truncate(:second)
  end
end
