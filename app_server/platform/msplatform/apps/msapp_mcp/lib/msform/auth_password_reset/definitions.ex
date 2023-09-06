# Source File: definitions.ex
# Location:    musebms/app_server/platform/msplatform/apps/msapp_mcp/lib/msform/auth_password_reset/definitions.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Msform.AuthPasswordReset.Definitions do
  alias MscmpSystForms.Types.FormConfig

  @moduledoc false

  def get_form_config do
    [
      %FormConfig{
        permission: :mcpauthnpr_form,
        label: "MCP Password Reset",
        info:
          "Password form used for the self-service password changes of already authenticated users.",
        children: [
          %FormConfig{
            form_id: :mcpauthnpr_identifier,
            binding_id: :identifier,
            label: "Email",
            info: """
            A visual reference to provide some trust that the correct account is having its password reset.
            """
          },
          %FormConfig{
            form_id: :mcpauthnpr_credential,
            binding_id: :credential,
            label: "Current Password",
            info: """
            The password credential which currently authenticates the identified Access Account.
            """
          },
          %FormConfig{
            form_id: :mcpauthnpr_new_credential,
            binding_id: :new_credential,
            label: "New Password",
            info: """
            The new password credential which will be used in future logins.
            """
          },
          %FormConfig{
            form_id: :mcpauthnpr_verify_credential,
            binding_id: :verify_credential,
            label: "Verify New Password",
            info: """
            Verification that the new password is entered correctly.  Must match the New Password.
            """
          },
          %FormConfig{
            form_id: :mcpauthnpr_button_reset,
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
          mcpauthnpr_identifier: %{component_mode: :visible},
          mcpauthnpr_credential: %{component_mode: :visible},
          mcpauthnpr_new_credential: %{component_mode: :visible},
          mcpauthnpr_verify_credential: %{component_mode: :visible},
          mcpauthnpr_button_reset: %{component_mode: :visible}
        },
        entry: %{
          reset: %{
            mcpauthnpr_identifier: %{component_mode: :visible},
            mcpauthnpr_credential: %{component_mode: :entry},
            mcpauthnpr_new_credential: %{component_mode: :entry},
            mcpauthnpr_verify_credential: %{component_mode: :entry},
            mcpauthnpr_button_reset: %{component_mode: :entry}
          }
        }
      },
      processing_overrides: %{
        mcpauthnpr_credential: [:process_password_reset],
        mcpauthnpr_new_credential: [:process_password_reset],
        mcpauthnpr_verify_credential: [:process_password_reset],
        mcpauthnpr_button_reset: [:process_password_reset]
      }
    }
  end
end
