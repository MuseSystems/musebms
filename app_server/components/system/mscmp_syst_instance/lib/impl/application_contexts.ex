# Source File: application_contexts.ex
# Location:    musebms/app_server/components/system/mscmp_syst_instance/lib/impl/application_contexts.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystInstance.Impl.ApplicationContexts do
  @moduledoc false

  import Ecto.Query

  alias MscmpSystInstance.Types

  ##############################################################################
  #
  # create_application_context
  #
  #

  @spec create_application_context(Types.application_context_params()) ::
          {:ok, Msdata.SystApplicationContexts.t()} | {:error, term()}
  def create_application_context(application_context_params) do
    application_context_params
    |> Msdata.SystApplicationContexts.insert_changeset()
    |> MscmpSystDb.insert(returning: true)
  end

  ##############################################################################
  #
  # get_application_context_id_by_name
  #
  #

  @spec get_application_context_id_by_name(Types.application_context_name()) ::
          Types.application_context_id() | nil
  def get_application_context_id_by_name(application_context_name)
      when is_binary(application_context_name) do
    from(ac in Msdata.SystApplicationContexts,
      where: ac.internal_name == ^application_context_name,
      select: ac.id
    )
    |> MscmpSystDb.one()
  end

  ##############################################################################
  #
  # update_application_context
  #
  #

  @spec update_application_context(
          Types.application_context_id() | Msdata.SystApplicationContexts.t(),
          Types.application_context_params()
        ) :: {:ok, Msdata.SystApplicationContexts.t()} | {:error, term()}
  def update_application_context(application_context_id, application_context_params)
      when is_binary(application_context_id) do
    case MscmpSystDb.get(Msdata.SystApplicationContexts, application_context_id) do
      nil ->
        {:error, {:not_found, application_context_id}}

      application_context ->
        update_application_context(application_context, application_context_params)
    end
  end

  def update_application_context(
        %Msdata.SystApplicationContexts{} = application_context,
        application_context_params
      ) do
    application_context
    |> Msdata.SystApplicationContexts.update_changeset(application_context_params)
    |> MscmpSystDb.update(returning: true)
  end

  ##############################################################################
  #
  # delete_application_context
  #
  #

  @spec delete_application_context(Types.application_context_id()) ::
          :ok | {:error, term()}
  def delete_application_context(application_context_id) do
    from(ac in Msdata.SystApplicationContexts, where: ac.id == ^application_context_id)
    |> MscmpSystDb.delete_all()
    |> case do
      {0, _} -> {:error, {:not_found, application_context_id}}
      {1, _} -> :ok
      error -> {:error, {:database_error, error}}
    end
  end

  ##############################################################################
  #
  # list_application_contexts
  #
  #

  @spec list_application_contexts(Types.application_id() | nil) ::
          {:ok, list(Msdata.SystApplicationContexts.t())} | {:error, term()}
  def list_application_contexts(application_id) do
    from(ac in Msdata.SystApplicationContexts)
    |> maybe_filter_by_application_id(application_id)
    |> MscmpSystDb.all()
    |> case do
      [] -> {:error, {:not_found, application_id}}
      application_contexts -> {:ok, application_contexts}
    end
  end

  defp maybe_filter_by_application_id(query, nil), do: query

  defp maybe_filter_by_application_id(query, application_id) do
    where(query, [q], q.application_id == ^application_id)
  end
end
