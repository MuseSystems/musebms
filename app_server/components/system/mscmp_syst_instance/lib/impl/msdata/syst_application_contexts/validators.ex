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

defmodule MscmpSystInstance.Impl.Msdata.SystApplicationContexts.Validators do
  @moduledoc false

  import Ecto.Changeset
  import Ecto.Query

  alias MscmpSystInstance.Impl.Msdata.GeneralValidators
  alias MscmpSystInstance.Impl.Msdata.Helpers
  alias MscmpSystInstance.Types

  @spec insert_changeset(Types.application_context_params(), Keyword.t()) :: Ecto.Changeset.t()
  def insert_changeset(insert_params, opts) do
    opts = MscmpSystUtils.resolve_options(opts, Helpers.option_defaults())

    resolved_insert_params = resolve_name_params(insert_params, :insert)

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
    |> validate_common(opts)
  end

  @spec update_changeset(
          Msdata.SystApplicationContexts.t(),
          Types.application_context_params(),
          Keyword.t()
        ) ::
          Ecto.Changeset.t()
  def update_changeset(application_context, update_params, opts) do
    opts = MscmpSystUtils.resolve_options(opts, Helpers.option_defaults())

    application_context
    |> cast(update_params, [:display_name, :description, :start_context])
    |> optimistic_lock(:diag_row_version)
    |> validate_common(opts)
  end

  defp validate_common(changeset, opts) do
    changeset
    |> GeneralValidators.validate_internal_name(opts)
    |> GeneralValidators.validate_display_name(opts)
    |> validate_required([
      :internal_name,
      :display_name,
      :application_id,
      :description,
      :start_context,
      :login_context,
      :database_owner_context
    ])
    |> unique_constraint(:internal_name, name: :syst_application_contexts_internal_name_udx)
    |> unique_constraint(:display_name, name: :syst_application_contexts_display_name_udx)
    |> foreign_key_constraint(:application_id, name: :syst_application_contexts_applications_fk)
  end

  # Currently the operation parameter has no real use and is maintained here for
  # consistency with helper functions found elsewhere in the code base.  We'll
  # go ahead and ensure that the only operation expected (:insert) is checked
  # just as an extra check on correct usage.

  defp resolve_name_params(application_context_params, :insert = _operation),
    do: resolve_application_id(application_context_params)

  defp resolve_application_id(%{application_name: application_name} = application_context_params)
       when is_binary(application_name) do
    from(a in Msdata.SystApplications, where: a.internal_name == ^application_name, select: a.id)
    |> MscmpSystDb.one!()
    |> then(&Map.put(application_context_params, :application_id, &1))
  end

  defp resolve_application_id(application_context_params), do: application_context_params
end
