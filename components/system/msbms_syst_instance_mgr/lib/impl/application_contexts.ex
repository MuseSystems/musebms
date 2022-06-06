# Source File: application_contexts.ex
# Location:    components/system/msbms_syst_instance_mgr/lib/impl/application_contexts.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystInstanceMgr.Impl.ApplicationContexts do
  import Ecto.Query

  require Logger

  alias MsbmsSystInstanceMgr.Data
  alias MsbmsSystInstanceMgr.Types

  @moduledoc false

  @spec get_application_contexts(
          Keyword.t(
            application_name: String.t() | nil,
            application_id: Ecto.UUID.t() | nil,
            start_context: boolean() | nil,
            login_context: boolean() | nil
          )
        ) ::
          {:ok, [Data.SystApplicationContexts.t()]} | {:error, MsbmsSystError.t()}
  def get_application_contexts(opts_given) do
    opts_default = [
      application_name: nil,
      application_id: nil,
      start_context: nil,
      login_context: nil
    ]

    opts = Keyword.merge(opts_given, opts_default, fn _k, v1, _v2 -> v1 end)

    get_application_context_base_query()
    |> order_by([application: a, application_context: ac], [a.display_name, ac.display_name])
    |> maybe_add_application_name_filter(opts[:application_name])
    |> maybe_add_application_id_filter(opts[:application_id])
    |> maybe_add_start_context_filter(opts[:start_context])
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
          message: "Failure retrieving Application Contexts.",
          cause: error
        }
      }
  end

  defp maybe_add_application_name_filter(query, nil), do: query

  defp maybe_add_application_name_filter(query, application_name)
       when is_binary(application_name) do
    from([application: a] in query, where: a.internal_name == ^application_name)
  end

  defp maybe_add_application_id_filter(query, nil), do: query

  defp maybe_add_application_id_filter(query, application_id) when is_binary(application_id) do
    from([application: a] in query, where: a.id == ^application_id)
  end

  defp maybe_add_start_context_filter(query, nil), do: query

  defp maybe_add_start_context_filter(query, start_context) when is_boolean(start_context) do
    from([application_context: ac] in query, where: ac.start_context == ^start_context)
  end

  defp maybe_add_login_context_filter(query, nil), do: query

  defp maybe_add_login_context_filter(query, login_context) when is_boolean(login_context) do
    from([application_context: ac] in query, where: ac.login_context == ^login_context)
  end

  @spec get_application_context_by_name(Types.application_context_name()) ::
          {:ok, Data.SystApplicationContexts.t()} | {:error, MsbmsSystError.t()}
  def get_application_context_by_name(application_context_name)
      when is_binary(application_context_name) do
    get_application_context_base_query()
    |> where([application_context: ac], ac.internal_name == ^application_context_name)
    |> MsbmsSystDatastore.one!()
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure retrieving Application Context by Name.",
          cause: error
        }
      }
  end

  @spec get_application_context_by_id(Types.application_context_id()) ::
          {:ok, Data.SystApplicationContexts.t()} | {:error, MsbmsSystError.t()}
  def get_application_context_by_id(application_context_id)
      when is_binary(application_context_id) do
    get_application_context_base_query()
    |> where([application_context: ac], ac.id == ^application_context_id)
    |> MsbmsSystDatastore.one!()
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure retrieving Application Context by ID.",
          cause: error
        }
      }
  end

  # Enough of these functions are just variations on a theme that we might as
  # well have a statement of that theme.
  defp get_application_context_base_query() do
    from(ac in Data.SystApplicationContexts,
      as: :application_context,
      join: a in assoc(ac, :application),
      as: :application,
      preload: [application: a]
    )
  end

  @spec get_application_context_id_by_name(Types.application_context_name()) :: Ecto.UUID.t()
  def get_application_context_id_by_name(application_context_name)
      when is_binary(application_context_name) do
    from(ac in Data.SystApplicationContexts,
      where: ac.internal_name == ^application_context_name,
      select: ac.id
    )
    |> MsbmsSystDatastore.one!()
  end

  @spec set_application_context_start_context(Types.application_context_id(), boolean()) ::
          {:ok, Data.SystApplicationContexts.t()}
          | {:error, MsbmsSystError.t()}
  def set_application_context_start_context(application_context_id, start_context) do
    MsbmsSystDatastore.get!(Data.SystApplicationContexts, application_context_id)
    |> Data.SystApplicationContexts.update_changeset(start_context)
    |> MsbmsSystDatastore.update!(returning: true)
    |> then(&{:ok, &1})
  end
end
