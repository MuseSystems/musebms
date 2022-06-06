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

  alias MsbmsSystInstanceMgr.Data

  require Logger

  @moduledoc false

  ######
  #
  # Logic for managing and accessing SystApplications data.
  #
  ######

  @spec list_applications() :: {:ok, list()} | {:error, MsbmsSystError.t()}
  def list_applications do
    app_list =
      from(a in Data.SystApplications,
        select: [:id, :internal_name, :display_name, :syst_description],
        order_by: [:display_name]
      )
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
end
