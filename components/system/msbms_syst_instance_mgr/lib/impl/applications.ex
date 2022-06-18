# Source File: applications.ex
# Location:    components/system/msbms_syst_instance_mgr/lib/impl/applications.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystInstanceMgr.Impl.Applications do
  import Ecto.Query
  import MsbmsSystUtils

  alias MsbmsSystInstanceMgr.Data

  require Logger

  @moduledoc false

  ######
  #
  # Logic for managing and accessing SystApplications data.
  #
  ######

  @spec list_applications(Keyword.t(sorts: list(:application)) | [] | nil) ::
          {:ok, list(Data.SystApplications.t())} | {:error, MsbmsSystError.t()}
  def list_applications(opts_given) do
    opts = resolve_options(opts_given, sorts: [])

    app_list =
      from(a in Data.SystApplications, as: :applications)
      |> maybe_add_sorts(opts[:sorts])
      |> MsbmsSystDatastore.all()

    {:ok, app_list}
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure retrieving applications list.",
          cause: error
        }
      }
  end

  defp maybe_add_sorts(query, [_ | _] = sorts) do
    Enum.reduce(sorts, query, &add_sort(&1, &2))
  end

  defp maybe_add_sorts(query, _sorts), do: query

  defp add_sort(:application, query), do: order_by(query, [applications: a], a.display_name)

  defp add_sort(sort, _query) do
    raise MsbmsSystError,
      code: :invalid_parameter,
      message: "Invalid sort requested.",
      cause: sort
  end
end
