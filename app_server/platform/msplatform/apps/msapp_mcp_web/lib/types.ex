# Source File: types.ex
# Location:    musebms/app_server/platform/msplatform/apps/msapp_mcp_web/lib/types.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsappMcpWeb.Types do
  @moduledoc """
  Defines Msplatform/MsappMcpWeb data types which appear in processing
  functionality.
  """

  @type form_data_def() :: %{required(form_field_name()) => form_field_def()}

  @type form_field_def() :: %{
          required(:label) => String.t(),
          required(:info) => String.t()
        }

  @type form_field_name() :: atom()

  @type mcp_bootstrap_params() :: %{
          optional(:owner_name) => String.t() | nil,
          optional(:owner_display_name) => String.t() | nil,
          optional(:admin_access_account_display_name) => String.t() | nil,
          optional(:admin_identifier) => String.t() | nil,
          optional(:admin_credential) => String.t() | nil,
          optional(:admin_credential_verify) => String.t() | nil
        }

  @type mcp_bootstrap_text() :: %{
          required(:owner_name) => String.t(),
          required(:owner_display_name) => String.t(),
          required(:admin_access_account_display_name) => String.t(),
          required(:admin_identifier) => String.t(),
          required(:admin_credential) => String.t(),
          required(:admin_credential_verify) => String.t()
        }
end
