# Source File: auth_password_reset.ex
# Location:    musebms/app_server/platform/msplatform/apps/msapp_mcp/lib/api/msform/auth_password_reset.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Msform.AuthPasswordReset do
  @moduledoc """
  Form/API data used for the user self-service password reset process.
  """

  use Ecto.Schema
  use MscmpSystForms

  alias MsappMcp.Impl.Msform.AuthPasswordReset.Actions
  alias MsappMcp.Impl.Msform.AuthPasswordReset.Data
  alias MsappMcp.Impl.Msform.AuthPasswordReset.Definitions
  alias MscmpSystAuthn.Types, as: AuthnTypes

  @type parameters() :: %{
          optional(:identifier) => String.t() | nil,
          optional(:credential) => String.t() | nil,
          optional(:new_credential) => String.t() | nil,
          optional(:verify_credential) => String.t() | nil
        }

  @type t() ::
          %__MODULE__{
            access_account_id: AuthnTypes.access_account_id(),
            identifier: String.t(),
            credential: String.t() | nil,
            new_credential: String.t() | nil,
            verify_credential: String.t() | nil
          }

  embedded_schema do
    field(:access_account_id, :string)
    field(:identifier, :string)
    field(:credential, :string, redact: true)
    field(:new_credential, :string, redact: true)
    field(:verify_credential, :string, redact: true)
  end

  @impl true
  @spec validate_save(Msform.AuthPasswordReset.t(), parameters()) :: Ecto.Changeset.t()
  defdelegate validate_save(original_data, current_data), to: Data

  @impl true
  @spec validate_post(Msform.AuthPasswordReset.t(), parameters()) :: Ecto.Changeset.t()
  defdelegate validate_post(original_data, current_data), to: Data

  @impl true
  defdelegate get_form_config, to: Definitions

  @impl true
  defdelegate get_form_modes, to: Definitions

  @impl true
  defdelegate preconnect_init(socket, session_name, feature, mode, state, opts \\ []), to: Actions

  @impl true
  defdelegate postconnect_init(form_config), to: Actions

  defdelegate validate_form_data(socket, form_data), to: Actions

  defdelegate process_reset_attempt(socket), to: Actions

  defdelegate process_reset_finished(socket), to: Actions
end
