# Source File: application.ex
# Location:    musebms/components/system/mscmp_syst_instance/lib/impl/application.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystInstance.Impl.Application do
  import Ecto.Query

  alias MscmpSystInstance.Types

  require Logger

  @moduledoc false

  # Note that this module, despite the name, is not the OTP Application related
  # code.  Please see `MscmpSystInstance.Runtime.Application` for that code.
  # This module is for working with `Msdata.SystApplications` records.

  @spec create_application(Types.application_params()) ::
          {:ok, Msdata.SystApplications.t()} | {:error, MscmpSystError.t()}
  def create_application(application_params) do
    application_params
    |> Msdata.SystApplications.insert_changeset(min_internal_name_length: 3)
    |> MscmpSystDb.insert!(returning: true)
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure creating new Application.",
         cause: error
       }}
  end

  @spec update_application(
          Types.application_id() | Msdata.SystApplications.t(),
          Types.application_params()
        ) :: {:ok, Msdata.SystApplications.t()} | {:error, MscmpSystError.t()}
  def update_application(application_id, application_params) when is_binary(application_id) do
    MscmpSystDb.get!(Msdata.SystApplications, application_id)
    |> update_application(application_params)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure updating Application record by ID.",
         cause: error
       }}
  end

  def update_application(%Msdata.SystApplications{} = application, application_params) do
    application
    |> Msdata.SystApplications.update_changeset(application_params)
    |> MscmpSystDb.update!(returning: true)
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure updating new Application.",
         cause: error
       }}
  end

  @spec get_application_id_by_name(Types.application_name()) :: Types.application_id() | nil
  def get_application_id_by_name(application_name) when is_binary(application_name) do
    from(a in Msdata.SystApplications, where: a.internal_name == ^application_name, select: a.id)
    |> MscmpSystDb.one()
  end

  @spec get_application(Types.application_id() | Types.application_name(), Keyword.t()) ::
          Msdata.SystApplications.t() | nil
  def get_application(application, opts) when is_binary(application) do
    opts = MscmpSystUtils.resolve_options(opts, include_contexts: false)

    application
    |> Ecto.UUID.cast()
    |> get_application_record_query(application)
    |> maybe_add_contexts_preload(opts[:include_contexts])
    |> MscmpSystDb.one()
  end

  defp get_application_record_query({:ok, _}, application_id),
    do: from(a in Msdata.SystApplications, select: a, where: a.id == ^application_id)

  defp get_application_record_query(:error, application_name),
    do: from(a in Msdata.SystApplications, select: a, where: a.internal_name == ^application_name)

  defp maybe_add_contexts_preload(query, true = _add_contexts) do
    query
    |> join(:inner, [a], ac in assoc(a, :application_contexts))
    |> preload([a, ac], application_contexts: ac)
  end

  defp maybe_add_contexts_preload(query, false = _add_contexts), do: query
end
