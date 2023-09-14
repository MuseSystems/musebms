# Source File: definitions.ex
# Location:    musebms/app_server/platform/msplatform/apps/msapp_mcp/lib/msform/mcp_bootstrap/definitions.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Msform.McpBootstrap.Definitions do
  @moduledoc false

  alias MscmpSystForms.Types.{ComponentDisplayModes, FormConfig}

  def get_form_config do
    [
      %FormConfig{
        permission: :mcpbs_bootstrap_form,
        label: "MCP Bootstrap",
        info: "This is a test of the info field for the MCP Bootstrap form.",
        children: [
          %FormConfig{
            form_id: :mcpbps_progress_list,
            children: [
              %FormConfig{form_id: :mcpbs_progress_item_welcome},
              %FormConfig{form_id: :mcpbs_progress_item_disallowed},
              %FormConfig{form_id: :mcpbs_progress_item_records},
              %FormConfig{form_id: :mcpbs_progress_item_finish}
            ]
          },
          %FormConfig{
            form_id: :mcpbs_step_welcome,
            children: [
              %FormConfig{
                form_id: :mcpbs_step_welcome_button_next
              },
              %FormConfig{
                form_id: :mcpbs_comment_welcome
              }
            ]
          },
          %FormConfig{
            form_id: :mcpbs_step_disallowed,
            children: [
              %FormConfig{
                form_id: :mcpbs_step_disallowed_button_load,
                button_state: :message
              },
              %FormConfig{
                form_id: :mcpbs_step_disallowed_button_back
              },
              %FormConfig{
                form_id: :mcpbs_step_disallowed_button_next
              },
              %FormConfig{
                form_id: :mcpbs_comment_disallowed
              }
            ]
          },
          %FormConfig{
            form_id: :mcpbs_step_records,
            children: [
              %FormConfig{
                form_id: :mcpbs_step_records_owner_group,
                label: "Platform Owner Setup Fields",
                info: "Platform Owner Descriptive Text",
                children: [
                  %FormConfig{
                    form_id: :mcpbs_step_records_field_owner_name,
                    binding_id: :owner_name,
                    label: "Owner Code",
                    info: """
                    A six character alpha-numeric code which uniquely identifies the system
                    Owner.  This value should have been provided to you by Muse Systems.
                    """
                  },
                  %FormConfig{
                    form_id: :mcpbs_step_records_field_owner_display_name,
                    binding_id: :owner_display_name,
                    label: "Owner Display Name",
                    info: """
                    The full name of the Owner visible through system user interfaces.  This
                    field must be at least 3 characters long and no more than 40.  20 or fewer
                    characters are recommended.
                    """
                  }
                ]
              },
              %FormConfig{
                form_id: :mcpbs_step_records_admin_group,
                label: "Platform Administrator Access Account Fields",
                children: [
                  %FormConfig{
                    form_id: :mcpbs_step_records_field_admin_display_name,
                    binding_id: :admin_display_name,
                    label: "Display/Full Name",
                    info: """
                    The full name of the Platform Administrator user account visible through
                    system user interfaces.  This value is required and must be at least 3
                    characters long and no more than 40.  20 or fewer characters are
                    recommended.
                    """
                  },
                  %FormConfig{
                    form_id: :mcpbs_step_records_field_admin_identifier,
                    binding_id: :admin_identifier,
                    label: "Email Address (User Name)",
                    label_link:
                      "/documentation/user/index.html#mcpbs_step_records_field_admin_identifier",
                    info: """
                    The email address of the Platform Administrator user account.  This value
                    is required and will be used as the Platform Administrator's user name
                    when logging into the system.  The value provided must be in the form of a
                    valid email address (e.g. "name@example.com").
                    """
                  },
                  %FormConfig{
                    form_id: :mcpbs_step_records_field_admin_credential,
                    binding_id: :admin_credential,
                    label: "Password",
                    label_link:
                      "/documentation/user/index.html#mcpbs_step_records_field_admin_credential",
                    info: """
                    The password the Platform Administrator will use to log into the system.
                    This value is required and by default must be 8 or more characters long,
                    no longer than 128 characters, and may not be a "Disallowed Password".
                    The Disallowed Passwords List is a list of passwords in the system which
                    are expected to be vulnerable to attack by malicious parties.
                    """
                  },
                  %FormConfig{
                    form_id: :mcpbs_step_records_field_admin_credential_verify,
                    binding_id: :admin_credential_verify,
                    label: "Verify Password",
                    info: """
                    Provides confirmation that the value entered in the "Password" field is
                    correct and repeatable.  This value is required and must match the value
                    of the "Password" field exactly.
                    """
                  },
                  %FormConfig{
                    form_id: :mcpbs_step_records_button_save,
                    button_state: :message
                  },
                  %FormConfig{
                    form_id: :mcpbs_step_records_button_back
                  }
                ]
              },
              %FormConfig{
                form_id: :mcpbs_comment_records
              }
            ]
          },
          %FormConfig{
            form_id: :mcpbs_step_finish,
            children: [
              %FormConfig{
                form_id: :mcpbs_step_finish_button_finish
              },
              %FormConfig{
                form_id: :mcpbs_comment_finish
              }
            ]
          }
        ]
      }
    ]
  end

  def get_form_modes do
    %{
      default: %{
        default: %{
          mcpbs_step_welcome: %ComponentDisplayModes{component_mode: :removed},
          mcpbs_step_disallowed: %ComponentDisplayModes{component_mode: :removed},
          mcpbs_step_records: %ComponentDisplayModes{component_mode: :removed},
          mcpbs_step_finish: %ComponentDisplayModes{component_mode: :removed},
          mcpbps_progress_list: %ComponentDisplayModes{component_mode: :visible}
        },
        entry: %{
          welcome: %{
            mcpbs_progress_item_welcome: %ComponentDisplayModes{text_mode: :emphasis},
            mcpbs_step_welcome: %ComponentDisplayModes{component_mode: :entry},
            mcpbs_comment_welcome_section: %ComponentDisplayModes{border_mode: :warning}
          },
          disallowed: %{
            mcpbs_progress_item_disallowed: %ComponentDisplayModes{text_mode: :emphasis},
            mcpbs_step_disallowed: %ComponentDisplayModes{component_mode: :entry}
          },
          records: %{
            mcpbs_progress_item_records: %ComponentDisplayModes{text_mode: :emphasis},
            mcpbs_step_records: %ComponentDisplayModes{component_mode: :entry}
          },
          finished: %{
            mcpbs_progress_item_finish: %ComponentDisplayModes{text_mode: :emphasis},
            mcpbs_step_finish: %ComponentDisplayModes{component_mode: :entry}
          }
        },
        processing_overrides: %{
          mcpbs_step_disallowed_button_load: [:process_disallowed_load],
          mcpbs_step_disallowed_button_back: [:process_disallowed_load],
          mcpbs_step_disallowed_button_next: [:process_disallowed_load],
          mcpbs_step_records_field_owner_name: [:process_records_save],
          mcpbs_step_records_field_owner_display_name: [:process_records_save],
          mcpbs_step_records_field_admin_display_name: [:process_records_save],
          mcpbs_step_records_field_admin_identifier: [:process_records_save],
          mcpbs_step_records_field_admin_credential: [:process_records_save],
          mcpbs_step_records_field_admin_credential_verify: [:process_records_save],
          mcpbs_step_records_button_back: [:process_records_save],
          mcpbs_step_records_button_save: [:process_records_save],
          mcpbs_step_records_form: [:process_records_save]
        }
      }
    }
  end
end
