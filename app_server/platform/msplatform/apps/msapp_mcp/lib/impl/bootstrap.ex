# Source File: bootstrap.ex
# Location:    musebms/app_server/platform/msplatform/apps/msapp_mcp/lib/impl/bootstrap.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsappMcp.Impl.Bootstrap do
  @moduledoc false

  alias MsappMcp.Types
  @spec load_disallowed_passwords() :: :ok | {:error, MscmpSystError.t()}
  def load_disallowed_passwords() do
    Path.join([
      :code.priv_dir(:msapp_mcp),
      "database",
      "mcp_disallowed_passwords_starter_list.txt"
    ])
    |> File.stream!()
    |> MssubMcp.load_disallowed_passwords(pg_format: true)
  end
end
