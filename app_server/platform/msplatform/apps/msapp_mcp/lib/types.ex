# Source File: types.ex
# Location:    musebms/app_server/platform/msplatform/apps/msapp_mcp/lib/types.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsappMcp.Types do
  @moduledoc """
  Defines Msplatform/MsappMcp data types which appear in processing
  functionality.
  """

  @type form_data_def() :: %{required(form_field_name()) => form_field_def()}

  @type form_field_def() :: %{
          required(:label) => String.t(),
          required(:info) => String.t()
        }

  @type form_field_name() :: atom()

  @type mssub_mcp_states() :: :platform_bootstrapping | :platform_active
end
