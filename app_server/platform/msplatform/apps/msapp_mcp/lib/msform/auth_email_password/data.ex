# Source File: data.ex
# Location:    musebms/app_server/platform/msplatform/apps/msapp_mcp/lib/msform/auth_email_password/data.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Msform.AuthEmailPassword.Data do
  import Ecto.Changeset

  alias Msform.AuthEmailPassword.Types

  @moduledoc false

  @spec validate_save(Msform.AuthEmailPassword.t(), Types.parameters()) :: Ecto.Changeset.t()
  def validate_save(original_data, current_data), do: validate_post(original_data, current_data)

  @spec validate_post(Msform.AuthEmailPassword.t(), Types.parameters()) :: Ecto.Changeset.t()
  def validate_post(original_data, current_data) do
    original_data
    |> cast(current_data, [:identifier, :credential])
    |> validate_required([:identifier, :credential])
  end
end
