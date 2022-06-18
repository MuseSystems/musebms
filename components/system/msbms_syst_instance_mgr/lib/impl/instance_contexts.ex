# Source File: instance_contexts.ex
# Location:    components/system/msbms_syst_instance_mgr/lib/impl/instance_contexts.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystInstanceMgr.Impl.InstanceContexts do
  import Ecto.Query
  import MsbmsSystUtils

  require Logger

  alias MsbmsSystInstanceMgr.Data
  alias MsbmsSystInstanceMgr.Types

  @moduledoc false

  ######
  #
  # Logic for managing and accessing SystInstanceContexts data.
  #
  # Note that SystInstanceContexts records are created and destroyed
  # automatically in the database when SystInstances records are created or
  # destroyed.  This happens via database trigger on
  # msbms_syst_data.syst_instances and foreign key constraints on
  # msbms_syst_data.syst_instance_contexts.
  #
  ######

  @spec list_instance_contexts(
          Keyword.t(
            filters:
              Keyword.t(
                instance_id: Types.instance_id() | nil,
                instance_name: Types.instance_name() | nil,
                owner_id: Types.owner_id() | nil,
                owner_name: Types.owner_name() | nil,
                application_id: Types.application_id() | nil,
                application_name: Types.application_name() | nil,
                start_context: boolean() | nil,
                database_owner_context: boolean() | nil,
                login_context: boolean() | nil
              )
              | []
              | nil,
            extra_data: list(:instance | :application_context) | [] | nil
          )
          | []
        ) ::
          {:ok, [Data.SystInstanceContexts.t()]} | {:error, MsbmsSystError.t()}
  def list_instance_contexts(opts_given) do
    opts = resolve_options(opts_given, filters: [], extra_data: [])

    from(ic in Data.SystInstanceContexts,
      as: :instance_context,
      join: i in assoc(ic, :instance),
      as: :instance,
      join: ac in assoc(ic, :application_context),
      as: :application_context
    )
    |> maybe_add_filters(opts[:filters])
    |> maybe_add_extra_data(opts[:extra_data])
    |> MsbmsSystDatastore.all()
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure retrieving Instance Contexts.",
          cause: error
        }
      }
  end

  defp maybe_add_filters(query, [_ | _] = filters) do
    Enum.reduce(filters, query, &add_filter(&1, &2))
  end

  defp maybe_add_filters(query, _filters), do: query

  defp add_filter({:instance_id, instance_id}, query) when is_binary(instance_id) do
    from([instance_context: ic] in query, where: ic.instance_id == ^instance_id)
  end

  defp add_filter({:instance_name, instance_name}, query) when is_binary(instance_name) do
    from([instance: i] in query, where: i.internal_name == ^instance_name)
  end

  defp add_filter({:owner_id, owner_id}, query) when is_binary(owner_id) do
    from([instance: i] in query, where: i.owner_id == ^owner_id)
  end

  defp add_filter({:owner_name, owner_name}, query) when is_binary(owner_name) do
    from([instance: i] in query,
      join: o in assoc(i, :owner),
      as: :owners,
      where: o.internal_name == ^owner_name
    )
  end

  defp add_filter({:application_id, application_id}, query) when is_binary(application_id) do
    from([instance: i] in query, where: i.application_id == ^application_id)
  end

  defp add_filter({:application_name, application_name}, query)
       when is_binary(application_name) do
    from([instance: i] in query,
      join: a in assoc(i, :application),
      as: :applications,
      where: a.internal_name == ^application_name
    )
  end

  defp add_filter({:start_context, start_context}, query) when is_boolean(start_context) do
    from([application_context: ac] in query, where: ac.start_context == ^start_context)
  end

  defp add_filter({:database_owner_context, database_owner_context}, query)
       when is_boolean(database_owner_context) do
    from([application_context: ac] in query,
      where: ac.database_owner_context == ^database_owner_context
    )
  end

  defp add_filter({:login_context, login_context}, query) when is_boolean(login_context) do
    from([application_context: ac] in query,
      where: ac.login_context == ^login_context
    )
  end

  defp add_filter(filter, _query) do
    raise MsbmsSystError,
      code: :invalid_parameter,
      message: "Invalid filter requested.",
      cause: filter
  end

  defp maybe_add_extra_data(query, [_ | _] = extra_data) do
    Enum.reduce(extra_data, query, &add_preload(&1, &2))
  end

  defp maybe_add_extra_data(query, _extra_data), do: query

  defp add_preload(:instance, query) do
    from([instance: i] in query, preload: [instance: i])
  end

  defp add_preload(:application_context, query) do
    from([application_context: ac] in query, preload: [application_context: ac])
  end

  defp add_preload(extra_data, _query) do
    raise MsbmsSystError,
      code: :invalid_parameter,
      message: "Invalid extra data requested.",
      cause: extra_data
  end

  @spec set_instance_context_values(Types.instance_context_id(), Types.instance_context_params()) ::
          {:ok, Data.SystInstanceContexts.t()} | {:error, MsbmsSystError.t()}
  def set_instance_context_values(instance_context_id, instance_context_params) do
    MsbmsSystDatastore.get!(Data.SystInstanceContexts, instance_context_id)
    |> Data.SystInstanceContexts.update_changeset(instance_context_params)
    |> MsbmsSystDatastore.update!(returning: true)
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure updating Instance Context.",
          cause: error
        }
      }
  end
end
