# Source File: syst_application_contexts.ex
# Location:    musebms/components/system/mscmp_syst_instance/lib/msdata/validators/syst_application_contexts.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystInstance.Msdata.Validators.SystApplicationContexts do
  import Ecto.Changeset

  alias MscmpSystInstance.Msdata.Helpers
  alias MscmpSystInstance.Msdata.Validators
  alias MscmpSystInstance.Types

  @moduledoc false

  @spec insert_changeset(Types.application_context_params(), Keyword.t()) :: Ecto.Changeset.t()
  def insert_changeset(insert_params, opts) do
    opts = MscmpSystUtils.resolve_options(opts, Helpers.OptionDefaults.defaults())

    resolved_insert_params =
      Helpers.SystApplicationContexts.resolve_name_params(insert_params, :insert)

    %Msdata.SystApplicationContexts{}
    |> cast(resolved_insert_params, [
      :internal_name,
      :display_name,
      :application_id,
      :description,
      :start_context,
      :login_context,
      :database_owner_context
    ])
    |> Validators.General.validate_internal_name(opts)
    |> Validators.General.validate_display_name(opts)
    |> validate_required([
      :internal_name,
      :display_name,
      :application_id,
      :description,
      :start_context,
      :login_context,
      :database_owner_context
    ])
  end

  @spec update_changeset(
          Msdata.SystApplicationContexts.t(),
          Types.application_context_params(),
          Keyword.t()
        ) ::
          Ecto.Changeset.t()
  def update_changeset(application_context, update_params, opts) do
    opts = MscmpSystUtils.resolve_options(opts, Helpers.OptionDefaults.defaults())

    application_context
    |> cast(update_params, [:display_name, :description, :start_context])
    |> Validators.General.validate_display_name(opts)
    |> validate_required([
      :internal_name,
      :display_name,
      :application_id,
      :description,
      :start_context,
      :login_context,
      :database_owner_context
    ])
    |> optimistic_lock(:diag_row_version)
  end
end
