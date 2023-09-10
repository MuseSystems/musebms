# Source File: application_contexts.ex
# Location:    musebms/components/system/mscmp_syst_instance/lib/impl/application_contexts.ex
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

  require Logger

  @spec create_application_context(Types.application_context_params()) ::
          {:ok, Msdata.SystApplicationContexts.t()} | {:error, MscmpSystError.t()}
  def create_application_context(application_context_params) do
    application_context_params
    |> Msdata.SystApplicationContexts.insert_changeset()
    |> MscmpSystDb.insert!(returning: true)
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure creating new Application Context.",
         cause: error
       }}
  end

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

  @spec update_application_context(
          Types.application_context_id() | Msdata.SystApplicationContexts.t(),
          Types.application_context_params()
        ) :: {:ok, Msdata.SystApplicationContexts.t()} | {:error, MscmpSystError.t()}
  def update_application_context(application_context_id, application_context_params)
      when is_binary(application_context_id) do
    MscmpSystDb.get!(Msdata.SystApplicationContexts, application_context_id)
    |> update_application_context(application_context_params)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure updating Application Context by ID.",
         cause: error
       }}
  end

  def update_application_context(
        %Msdata.SystApplicationContexts{} = application_context,
        application_context_params
      ) do
    application_context
    |> Msdata.SystApplicationContexts.update_changeset(application_context_params)
    |> MscmpSystDb.update!(returning: true)
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure updating Application Context.",
         cause: error
       }}
  end

  @spec delete_application_context(Types.application_context_id()) ::
          {:ok, :deleted | :not_found} | {:error, MscmpSystError.t()}
  def delete_application_context(application_context_id) do
    from(ac in Msdata.SystApplicationContexts, where: ac.id == ^application_context_id)
    |> MscmpSystDb.delete_all()
    |> case do
      {0, _} ->
        {:ok, :not_found}

      {1, _} ->
        {:ok, :deleted}

      error ->
        {:error,
         %MscmpSystError{
           code: :undefined_error,
           message: "Unexpected result while deleting Application Context.",
           cause: error
         }}
    end
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure deleting Application Context.",
         cause: error
       }}
  end

  @spec list_application_contexts(Types.application_id() | nil) ::
          {:ok, list(Msdata.SystApplicationContexts.t())} | {:error, MscmpSystError.t()}
  def list_application_contexts(application_id) do
    from(ac in Msdata.SystApplicationContexts)
    |> maybe_filter_by_application_id(application_id)
    |> MscmpSystDb.all()
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure retrieving Application Contexts list.",
         cause: error
       }}
  end

  defp maybe_filter_by_application_id(query, nil), do: query

  defp maybe_filter_by_application_id(query, application_id) do
    where(query, [q], q.application_id == ^application_id)
  end
end
