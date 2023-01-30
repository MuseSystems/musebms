# Source File: mcp_bootstrap.ex
# Location:    musebms/app_server/platform/msplatform/apps/msapp_mcp/lib/msdata_api/mcp_bootstrap.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsdataApi.McpBootstrap do
  use Ecto.Schema

  alias MsdataApi.Validators
  alias MsappMcpWeb.Types

  @moduledoc """
  Form data used during the MCP Bootstrapping process.

  Note that currently the data assumes that only an email/password Authenticator
  will be provided for the administrative Access Account.
  """

  @type t() ::
          %__MODULE__{
            owner_name: String.t() | nil,
            owner_display_name: String.t() | nil,
            admin_access_account_display_name: String.t() | nil,
            admin_identifier: String.t() | nil,
            admin_credential: String.t() | nil,
            admin_credential_verify: String.t() | nil
          }

  embedded_schema do
    field(:owner_name, :string)
    field(:owner_display_name, :string)
    field(:admin_access_account_display_name, :string)
    field(:admin_identifier, :string, redact: true)
    field(:admin_credential, :string, redact: true)
    field(:admin_credential_verify, :string, redact: true)
  end

  @doc """
  Validates a map of form data for validation of form entry prior to final
  submission.
  """
  @spec changeset(MsdataApi.McpBootstrap.t(), Types.mcp_bootstrap_params()) :: Ecto.Changeset.t()
  defdelegate changeset(mcp_bootstrap, change_params \\ %{}), to: Validators.McpBootstrap

  @doc """
  Returns the user interface textual labels associated with each form field.

  We define these here so that the rest of the application has a common
  definition of how these form fields should be labelled.
  """
  @spec get_data_definition() :: Types.form_data_def()
  def get_data_definition do
    %{
      owner_name: %{
        label: "Owner Code",
        info: """
        A six character alpha-numeric code which uniquely identifies the system
        Owner.  This value should have been provided to you by Muse Systems.
        """
      },
      owner_display_name: %{
        label: "Owner Display Name",
        info: """
        The full name of the Owner visible through system user interfaces.  This
        field must be at least 3 characters long and no more than 40.  20 or fewer
        characters are recommended.
        """
      },
      admin_access_account_display_name: %{
        label: "Display/Full Name",
        info: """
        The full name of the Platform Administrator user account visible through
        system user interfaces.  This value is required and must be at least 3
        characters long and no more than 40.  20 or fewer characters are
        recommended.
        """
      },
      admin_identifier: %{
        label: "Email Address (User Name)",
        info: """
        The email address of the Platform Administrator user account.  This value
        is required and will be used as the Platform Administrator's user name
        when logging into the system.  The value provided must be in the form of a
        valid email address (e.g. "name@example.com").
        """
      },
      admin_credential: %{
        label: "Password",
        info: """
        The password the Platform Administrator will use to log into the system.
        This value is required and by default must be 8 or more characters long,
        no longer than 128 characters, and may not be a "Disallowed Password".
        The Disallowed Passwords List is a list of passwords in the system which
        are expected to be vulnerable to attack by malicious parties.
        """
      },
      admin_credential_verify: %{
        label: "Verify Password",
        info: """
        Provides confirmation that the value entered in the "Password" field is
        correct and repeatable.  This value is required and must match the value
        of the "Password" field exactly.
        """
      }
    }
  end
end
