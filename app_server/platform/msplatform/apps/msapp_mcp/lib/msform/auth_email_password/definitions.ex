# Source File: definitions.ex
# Location:    musebms/app_server/platform/msplatform/apps/msapp_mcp/lib/msform/auth_email_password/definitions.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Msform.AuthEmailPassword.Definitions do
  alias MscmpSystForms.Types.FormConfig

  @moduledoc false

  def get_form_config do
    [
      %FormConfig{
        permission: :mcpauthnep_form,
        label: "MCP Login Form",
        info: "Login form used for authenticating Application Platform users.",
        children: [
          %FormConfig{
            form_id: :mcpauthnep_form_identifier,
            binding_id: :identifier,
            label: "Email",
            info: """
            The email address which identifies the Access Account to authenticate.
            """
          },
          %FormConfig{
            form_id: :mcpauthnep_form_credential,
            binding_id: :credential,
            label: "Password",
            info: """
            The password credential which authenticates the identified Access Account.
            """
          },
          %FormConfig{
            form_id: :mcpauthnep_button_login,
            button_state: :message
          }
        ]
      }
    ]
  end

  def get_form_modes do
    %{
      default: %{
        default: %{
          mcpauthnep_form_identifier: %{component_mode: :visible},
          mcpauthnep_form_credential: %{component_mode: :visible},
          mcpauthnep_button_login: %{component_mode: :visible}
        },
        entry: %{
          login: %{
            mcpauthnep_form_identifier: %{component_mode: :entry},
            mcpauthnep_form_credential: %{component_mode: :entry},
            mcpauthnep_button_login: %{component_mode: :entry}
          }
        }
      },
      processing_overrides: %{
        mcpauthnep_form_identifier: [:process_login_attempt],
        mcpauthnep_form_credential: [:process_login_attempt],
        mcpauthnep_button_login: [:process_login_attempt]
      }
    }
  end
end
