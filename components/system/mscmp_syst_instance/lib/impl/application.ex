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

  @spec get_application_id_by_name(Types.application_name()) ::
          {:ok, Types.application_id() | :not_found} | {:error, MscmpSystErrot.t()}
  def get_application_id_by_name(application_name) when is_binary(application_name) do
    get_application_id_by_name!(application_name)
    |> case do
      nil -> {:ok, :not_found}
      id when is_binary(id) -> {:ok, id}
    end
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure retrieving Application record ID.",
         cause: error
       }}
  end

  @spec get_application_id_by_name!(Types.application_name()) :: Types.application_id() | nil
  def get_application_id_by_name!(application_name) when is_binary(application_name) do
    from(a in Msdata.SystApplications, where: a.internal_name == ^application_name, select: a.id)
    |> MscmpSystDb.one()
  end
end
