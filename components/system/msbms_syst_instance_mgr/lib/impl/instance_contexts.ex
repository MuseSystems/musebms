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
        ) ::
          {:ok, [Data.SystInstanceContexts.t()]} | {:error, MsbmsSystError.t()}
  def list_instance_contexts(opts_given) do
    opts_default = [
      instance_id: nil,
      instance_name: nil,
      owner_id: nil,
      owner_name: nil,
      application_id: nil,
      application_name: nil,
      start_context: nil,
      database_owner_context: nil,
      login_context: nil
    ]

    opts = Keyword.merge(opts_given, opts_default, fn _k, v1, _v2 -> v1 end)

    instance_context_base_query()
    |> maybe_add_instance_id_filter(opts[:instance_id])
    |> maybe_add_instance_name_filter(opts[:instance_name])
    |> maybe_add_owner_id_filter(opts[:owner_id])
    |> maybe_add_owner_name_filter(opts[:owner_name])
    |> maybe_add_application_id_filter(opts[:application_id])
    |> maybe_add_application_name_filter(opts[:application_name])
    |> maybe_add_start_context_filter(opts[:start_context])
    |> maybe_add_database_owner_context_filter(opts[:database_owner_context])
    |> maybe_add_login_context_filter(opts[:login_context])
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

  defp maybe_add_instance_id_filter(query, nil), do: query

  defp maybe_add_instance_id_filter(query, instance_id) when is_binary(instance_id) do
    from([instance_contexts: ic] in query, where: ic.instance_id == ^instance_id)
  end

  defp maybe_add_instance_name_filter(query, nil), do: query

  defp maybe_add_instance_name_filter(query, instance_name) when is_binary(instance_name) do
    from([instances: i] in query, where: i.internal_name == ^instance_name)
  end

  defp maybe_add_owner_id_filter(query, nil), do: query

  defp maybe_add_owner_id_filter(query, owner_id) when is_binary(owner_id) do
    from([instances: i] in query, where: i.owner_id == ^owner_id)
  end

  defp maybe_add_owner_name_filter(query, nil), do: query

  defp maybe_add_owner_name_filter(query, owner_name) when is_binary(owner_name) do
    from([instances: i] in query,
      join: o in assoc(i, :owner),
      as: :owners,
      where: o.internal_name == ^owner_name
    )
  end

  defp maybe_add_application_id_filter(query, nil), do: query

  defp maybe_add_application_id_filter(query, application_id) when is_binary(application_id) do
    from([instances: i] in query, where: i.application_id == ^application_id)
  end

  defp maybe_add_application_name_filter(query, nil), do: query

  defp maybe_add_application_name_filter(query, application_name)
       when is_binary(application_name) do
    from([instances: i] in query,
      join: a in assoc(i, :application),
      as: :applications,
      where: a.internal_name == ^application_name
    )
  end

  defp maybe_add_start_context_filter(query, nil), do: query

  defp maybe_add_start_context_filter(query, start_context) when is_boolean(start_context) do
    from([application_contexts: ac] in query, where: ac.start_context == ^start_context)
  end

  defp maybe_add_database_owner_context_filter(query, nil), do: query

  defp maybe_add_database_owner_context_filter(query, database_owner_context)
       when is_boolean(database_owner_context) do
    from([application_contexts: ac] in query,
      where: ac.database_owner_context == ^database_owner_context
    )
  end

  defp maybe_add_login_context_filter(query, nil), do: query

  defp maybe_add_login_context_filter(query, login_context) when is_boolean(login_context) do
    from([application_contexts: ac] in query,
      where: ac.login_context == ^login_context
    )
  end

  defp instance_context_base_query do
    from(ic in Data.SystInstanceContexts,
      as: :instance_contexts,
      join: i in assoc(ic, :instance),
      as: :instances,
      join: ac in assoc(ic, :application_context),
      as: :application_contexts,
      preload: [instance: i, application_context: ac]
    )
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
