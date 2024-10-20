# Source File: helpers.ex
# Location:    musebms/components/system/mscmp_syst_authn/lib/impl/identity/helpers.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystAuthn.Impl.Identity.Helpers do
  @moduledoc false

  import Ecto.Query

  require Logger

  def create_identity(create_params, opts) do
    create_params
    |> maybe_add_validated_date(opts[:create_validated])
    |> create_record()
  end

  defp maybe_add_validated_date(create_params, true),
    do: Map.put(create_params, :validated, DateTime.now!("Etc/UTC"))

  defp maybe_add_validated_date(create_params, false), do: create_params

  def delete_identity(identity_id) when is_binary(identity_id) do
    from(i in Msdata.SystIdentities, where: i.id == ^identity_id)
    |> MscmpSystDb.one!()
    |> delete_identity()
  end

  def create_record(insert_params) do
    insert_params
    |> Msdata.SystIdentities.insert_changeset()
    |> MscmpSystDb.insert!(returning: true)
  end

  def update_record(identity, update_params) do
    identity
    |> Msdata.SystIdentities.update_changeset(update_params)
    |> MscmpSystDb.update!(returning: true)
  end

  def delete_record(identity) do
    MscmpSystDb.delete!(identity)
    :ok
  end

  def get_identification_query(
        account_identifier,
        identity_type,
        owner_id,
        allow_unvalidated \\ :require_validation
      ) do
    from(
      i in Msdata.SystIdentities,
      as: :identity,
      join: it in assoc(i, :identity_type),
      as: :identity_type,
      join: aa in assoc(i, :access_account),
      as: :access_account,
      where: it.internal_name == ^identity_type and i.account_identifier == ^account_identifier,
      select: i,
      preload: [access_account: aa]
    )
    |> get_ident_query_owner_predicate(owner_id)
    |> get_ident_query_validation_predicate(allow_unvalidated)
  end

  defp get_ident_query_owner_predicate(query, owner_id) when is_binary(owner_id),
    do: where(query, [access_account: aa], aa.owning_owner_id == ^owner_id)

  defp get_ident_query_owner_predicate(query, owner_id) when is_nil(owner_id),
    do: where(query, [access_account: aa], is_nil(aa.owning_owner_id))

  defp get_ident_query_validation_predicate(query, :require_validation),
    do: where(query, [identity: i], not is_nil(i.validated))

  defp get_ident_query_validation_predicate(query, :require_unvalidated),
    do: where(query, [identity: i], is_nil(i.validated))

  defp get_ident_query_validation_predicate(query, :allow_unvalidated), do: query
end
