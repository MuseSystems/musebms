# Source File: identity.ex
# Location:    musebms/components/system/mscmp_syst_authn/lib/impl/identity.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystAuthn.Impl.Identity do
  @moduledoc false

  import Ecto.Query

  alias MscmpSystAuthn.Impl.Identity.Helpers
  alias MscmpSystAuthn.Types

  ##############################################################################
  #
  # Identity Behaviour Callbacks
  #
  #

  @callback create_identity(Types.access_account_id(), Types.account_identifier(), Keyword.t()) ::
              {:ok, Msdata.SystIdentities.t()} | {:error, term()}

  @callback identify_access_account(
              Types.account_identifier(),
              MscmpSystInstance.Types.owner_id() | nil
            ) :: {:ok, Msdata.SystIdentities.t()} | {:error, :not_found} | {:error, term()}

  ##############################################################################
  #
  # get_identity_type_by_name
  #
  #

  @spec get_identity_type_by_name(Types.identity_type_name()) :: Msdata.SystEnumItems.t() | nil
  def get_identity_type_by_name(identity_type_name) when is_binary(identity_type_name),
    do: MscmpSystEnums.get_item_by_name("identity_types", identity_type_name)

  ##############################################################################
  #
  # get_identity_type_default
  #
  #

  @spec get_identity_type_default(Types.identity_type_functional_types() | nil) ::
          Msdata.SystEnumItems.t()
  def get_identity_type_default(nil), do: MscmpSystEnums.get_default_item("identity_types")

  def get_identity_type_default(functional_type) when is_atom(functional_type) do
    MscmpSystEnums.get_default_item("identity_types",
      functional_type_name: Atom.to_string(functional_type)
    )
  end

  ##############################################################################
  #
  # set_identity_expiration
  #
  #

  @spec set_identity_expiration(Types.identity_id() | Msdata.SystIdentities.t(), DateTime.t()) ::
          {:ok, Msdata.SystIdentities.t()} | {:error, term()}
  def set_identity_expiration(identity_id, %DateTime{} = expires_date)
      when is_binary(identity_id) do
    with {:ok, identity} <- get_identity_record(identity_id) do
      Helpers.update_identity(identity, %{identity_expires: expires_date})
    end
  end

  def set_identity_expiration(%Msdata.SystIdentities{} = identity, %DateTime{} = expires_date),
    do: Helpers.update_identity(identity, %{identity_expires: expires_date})

  ##############################################################################
  #
  # clear_identity_expiration
  #
  #

  @spec clear_identity_expiration(Types.identity_id() | Msdata.SystIdentities.t()) ::
          {:ok, Msdata.SystIdentities.t()} | {:error, term()}
  def clear_identity_expiration(identity_id) when is_binary(identity_id) do
    with {:ok, identity} <- get_identity_record(identity_id) do
      Helpers.update_identity(identity, %{identity_expires: nil})
    end
  end

  def clear_identity_expiration(%Msdata.SystIdentities{} = identity),
    do: Helpers.update_identity(identity, %{identity_expires: nil})

  ##############################################################################
  #
  # identity_expired
  #
  #

  @spec identity_expired(Types.identity_id() | Msdata.SystIdentities.t()) ::
          {:ok, boolean()} | {:error, :not_found} | {:error, term()}
  def identity_expired(identity) when is_binary(identity) do
    from(i in Msdata.SystIdentities,
      where: i.id == ^identity,
      select: struct(i, [:identity_expires])
    )
    |> MscmpSystDb.one()
    |> case do
      nil -> {:error, :not_found}
      result -> identity_expired(result)
    end
  end

  def identity_expired(%Msdata.SystIdentities{} = identity) do
    case identity.identity_expires do
      nil -> {:ok, false}
      expires_date -> {:ok, DateTime.compare(DateTime.utc_now(), expires_date) == :gt}
    end
  end

  ##############################################################################
  #
  # identity_validated
  #
  #

  @spec identity_validated(Types.identity_id() | Msdata.SystIdentities.t()) ::
          {:ok, boolean()} | {:error, :not_found} | {:error, term()}
  def identity_validated(identity) when is_binary(identity) do
    from(i in Msdata.SystIdentities,
      where: i.id == ^identity,
      select: struct(i, [:validated])
    )
    |> MscmpSystDb.one()
    |> case do
      nil -> {:error, :not_found}
      result -> identity_validated(result)
    end
  end

  def identity_validated(%Msdata.SystIdentities{validated: validated})
      when not is_nil(validated),
      do: {:ok, true}

  def identity_validated(%Msdata.SystIdentities{}), do: {:ok, false}

  ##############################################################################
  #
  # delete_identity
  #
  #

  @spec delete_identity(
          Types.identity_id() | Msdata.SystIdentities.t(),
          Types.identity_type_name()
        ) ::
          :ok | {:error, :not_found} | {:error, term()}
  def delete_identity(identity_id, identity_type_name)
      when is_binary(identity_id) and is_binary(identity_type_name) do
    from(i in Msdata.SystIdentities,
      join: ei in assoc(i, :identity_type),
      where: i.id == ^identity_id and ei.internal_name == ^identity_type_name
    )
    |> MscmpSystDb.delete_all()
    |> case do
      {0, _} -> {:error, :not_found}
      {1, _} -> :ok
      error -> {:error, {:database_error, error}}
    end
  end

  def delete_identity(%Msdata.SystIdentities{} = identity, identity_type_name),
    do: delete_identity(identity.id, identity_type_name)

  ##############################################################################
  #
  # get_identity_record
  #
  #

  @spec get_identity_record(Types.identity_id()) ::
          {:ok, Msdata.SystIdentities.t()} | {:error, :not_found} | {:error, term()}
  def get_identity_record(identity_id) do
    from(i in Msdata.SystIdentities, where: i.id == ^identity_id)
    |> MscmpSystDb.one()
    |> case do
      nil -> {:error, :not_found}
      record -> {:ok, record}
    end
  end
end
