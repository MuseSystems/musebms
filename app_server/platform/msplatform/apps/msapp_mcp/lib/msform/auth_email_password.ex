# Source File: auth_email_password.ex
# Location:    musebms/app_server/platform/msplatform/apps/msapp_mcp/lib/msform/auth_email_password.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Msform.AuthEmailPassword do
  use Ecto.Schema
  use MscmpSystForms

  alias MsappMcp.Types
  alias Msform.AuthEmailPassword

  @moduledoc """
  Form/API data used the Email/Password authentication process.
  """

  @type t() ::
          %__MODULE__{
            identifier: String.t() | nil,
            credential: String.t() | nil
          }

  embedded_schema do
    field(:identifier, :string, redact: true)
    field(:credential, :string, redact: true)
  end

  @doc """
  Validates a map of form data for validation of form entry prior to final
  submission.
  """
  @impl true
  @spec validate_post(Msform.AuthEmailPassword.t(), Types.auth_email_password()) ::
          Ecto.Changeset.t()
  defdelegate validate_post(original_data, current_data \\ %{}), to: AuthEmailPassword.Data

  @impl true
  @spec validate_save(Msform.AuthEmailPassword.t(), Types.auth_email_password()) ::
          Ecto.Changeset.t()
  defdelegate validate_save(original_data, current_data \\ %{}), to: AuthEmailPassword.Data

  @doc """
  Returns the user interface textual labels associated with each form field.

  We define these here so that the rest of the application has a common
  definition of how these form fields should be labelled.
  """
  @impl true
  defdelegate get_form_config, to: AuthEmailPassword.Definitions

  @impl true
  defdelegate get_form_modes, to: AuthEmailPassword.Definitions

  @impl true
  defdelegate preconnect_init(socket, session_name, feature, mode, state, opts \\ []),
    to: AuthEmailPassword.Actions

  @impl true
  defdelegate postconnect_init(form_config), to: AuthEmailPassword.Actions

  defdelegate validate_form_data(socket, form_data), to: AuthEmailPassword.Actions

  defdelegate process_login_attempt(socket, form_data), to: AuthEmailPassword.Actions

  defdelegate process_login_denied(socket), to: AuthEmailPassword.Actions
end
