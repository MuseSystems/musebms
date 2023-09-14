# Source File: auth_password_reset.ex
# Location:    musebms/app_server/platform/msplatform/apps/msapp_mcp/lib/msform/auth_password_reset.ex
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

  alias MscmpSystAuthn.Types, as: AuthnTypes
  alias Msform.AuthPasswordReset.Types

  embedded_schema do
    field(:access_account_id, :string)
    field(:identifier, :string)
    field(:credential, :string, redact: true)
    field(:new_credential, :string, redact: true)
    field(:verify_credential, :string, redact: true)
  end

  @type t() ::
          %__MODULE__{
            access_account_id: AuthnTypes.access_account_id(),
            identifier: String.t(),
            credential: String.t() | nil,
            new_credential: String.t() | nil,
            verify_credential: String.t() | nil
          }

  @impl true
  @spec validate_save(
          Msform.AuthPasswordReset.t(),
          Types.parameters()
        ) :: Ecto.Changeset.t()
  defdelegate validate_save(original_data, current_data),
    to: Msform.AuthPasswordReset.Data

  @impl true
  @spec validate_post(
          Msform.AuthPasswordReset.t(),
          Types.parameters()
        ) :: Ecto.Changeset.t()
  defdelegate validate_post(original_data, current_data),
    to: Msform.AuthPasswordReset.Data

  @impl true
  defdelegate get_form_config, to: Msform.AuthPasswordReset.Definitions

  @impl true
  defdelegate get_form_modes, to: Msform.AuthPasswordReset.Definitions

  @impl true
  defdelegate preconnect_init(socket, session_name, feature, mode, state, opts \\ []),
    to: Msform.AuthPasswordReset.Actions

  @impl true
  defdelegate postconnect_init(form_config), to: Msform.AuthPasswordReset.Actions

  defdelegate validate_form_data(socket, form_data), to: Msform.AuthPasswordReset.Actions

  defdelegate process_reset_attempt(socket), to: Msform.AuthPasswordReset.Actions

  defdelegate process_reset_finished(socket), to: Msform.AuthPasswordReset.Actions
end
