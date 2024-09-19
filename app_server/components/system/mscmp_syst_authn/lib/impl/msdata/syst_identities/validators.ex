# Source File: validators.ex
# Location:    musebms/app_server/components/system/mscmp_syst_authn/lib/impl/msdata/syst_identities/validators.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystAuthn.Impl.Msdata.SystIdentities.Validators do
  @moduledoc false

  import Ecto.Changeset

  alias MscmpSystAuthn.Impl.Msdata.Helpers
  alias MscmpSystAuthn.Types

  ##############################################################################
  #
  # insert_changeset
  #
  #

  @spec insert_changeset(Types.identity_params()) :: Ecto.Changeset.t()
  def insert_changeset(insert_params) do
    resolved_insert_params = resolve_name_params(insert_params, :insert)

    %Msdata.SystIdentities{}
    |> cast(resolved_insert_params, [
      :access_account_id,
      :identity_type_id,
      :account_identifier,
      :validated,
      :validates_identity_id,
      :validation_requested,
      :identity_expires,
      :external_name
    ])
    |> validate_common()
  end

  ##############################################################################
  #
  # update_changeset
  #
  #

  @spec update_changeset(Msdata.SystIdentities.t(), Types.identity_params()) :: Ecto.Changeset.t()
  def update_changeset(identity, update_params) do
    identity
    |> cast(update_params, [
      :validated,
      :validation_requested,
      :identity_expires,
      :external_name
    ])
    |> validate_common()
    |> optimistic_lock(:diag_row_version)
  end

  defp validate_common(changeset) do
    validate_required(changeset, [
      :access_account_id,
      :identity_type_id,
      :account_identifier
    ])
    |> unique_constraint(:validates_identity_id, name: :syst_identities_validates_identities_udx)
    |> foreign_key_constraint(:access_account_id, name: :syst_identities_access_accounts_fk)
    |> foreign_key_constraint(:identity_type_id, name: :syst_identities_identity_types_fk)
    |> foreign_key_constraint(:validates_identity_id,
      name: :syst_identities_validates_identities_fk
    )
  end

  defp resolve_name_params(change_params, operation) do
    change_params
    |> Helpers.resolve_access_account_id()
    |> resolve_identity_type_id(operation)
  end

  defp resolve_identity_type_id(
         %{identity_type_name: identity_type_name} = change_params,
         _operation
       )
       when is_binary(identity_type_name) do
    identity_type = MscmpSystEnums.get_enum_item_by_name("identity_types", identity_type_name)

    Map.put(change_params, :identity_type_id, identity_type.id)
  end

  defp resolve_identity_type_id(
         %{identity_type_id: identity_type_id} = change_params,
         _operation
       )
       when is_binary(identity_type_id) do
    change_params
  end

  # TODO: Should we really be defaulting this value?  Is such defaulting valid?
  defp resolve_identity_type_id(change_params, :insert) do
    identity_type = MscmpSystEnums.get_default_enum_item("identity_types")

    Map.put(change_params, :identity_type_id, identity_type.id)
  end
end
