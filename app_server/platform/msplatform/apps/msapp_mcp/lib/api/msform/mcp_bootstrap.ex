# Source File: mcp_bootstrap.ex
# Location:    musebms/app_server/platform/msplatform/apps/msapp_mcp/lib/api/msform/mcp_bootstrap.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Msform.McpBootstrap do
  @moduledoc """
  Form data used during the MCP Bootstrapping process.

  Note that currently the data assumes that only an email/password Authenticator
  will be provided for the administrative Access Account.
  """

  use Ecto.Schema
  use MscmpSystForms

  alias MsappMcp.Impl.Msform.McpBootstrap.Actions
  alias MsappMcp.Impl.Msform.McpBootstrap.Data
  alias MsappMcp.Impl.Msform.McpBootstrap.Definitions

  @type parameters() :: %{
          optional(:owner_name) => String.t() | nil,
          optional(:owner_display_name) => String.t() | nil,
          optional(:admin_display_name) => String.t() | nil,
          optional(:admin_identifier) => String.t() | nil,
          optional(:admin_credential) => String.t() | nil,
          optional(:admin_credential_verify) => String.t() | nil
        }

  @type t() ::
          %__MODULE__{
            owner_name: String.t() | nil,
            owner_display_name: String.t() | nil,
            admin_display_name: String.t() | nil,
            admin_identifier: String.t() | nil,
            admin_credential: String.t() | nil,
            admin_credential_verify: String.t() | nil
          }

  embedded_schema do
    field(:owner_name, :string)
    field(:owner_display_name, :string)
    field(:admin_display_name, :string)
    field(:admin_identifier, :string, redact: true)
    field(:admin_credential, :string, redact: true)
    field(:admin_credential_verify, :string, redact: true)
  end

  @impl true
  defdelegate get_form_config, to: Definitions

  @impl true
  defdelegate get_form_modes, to: Definitions

  @impl true
  defdelegate preconnect_init(socket, session_name, feature, mode, state, opts \\ []), to: Actions

  @impl true
  defdelegate postconnect_init(form_config), to: Actions

  @doc """
  Validates a map of form data for validation of form entry prior to final
  submission.
  """
  @impl true
  @spec validate_save(Msform.McpBootstrap.t(), parameters()) :: Ecto.Changeset.t()
  defdelegate validate_save(original_data, current_data \\ %{}), to: Data

  @impl true
  @spec validate_post(Msform.McpBootstrap.t(), parameters()) :: Ecto.Changeset.t()
  defdelegate validate_post(original_data, current_data \\ %{}), to: Data

  defdelegate enter_disallowed_state(socket), to: Actions
  defdelegate enter_welcome_state(socket), to: Actions
  defdelegate enter_records_state(socket), to: Actions
  defdelegate enter_finished_state(socket), to: Actions
  defdelegate process_disallowed_load(socket), to: Actions
  defdelegate process_disallowed_finished(socket), to: Actions
  defdelegate process_records_save(socket), to: Actions
  defdelegate process_records_save_finished(socket), to: Actions
  defdelegate validate_form_data(socket, form_data), to: Actions
end
