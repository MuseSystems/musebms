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

  require Logger

  # Setup callbacks for Identity type specific calls

  @callback create_identity(Types.access_account_id(), Types.account_identifier(), Keyword.t()) ::
              {:ok, Msdata.SystIdentities.t()} | {:error, MscmpSystError.t() | Exception.t()}

  @callback identify_access_account(
              Types.account_identifier(),
              MscmpSystInstance.Types.owner_id() | nil
            ) :: Msdata.SystIdentities.t() | nil

  # General Identity functionality

  @spec get_identity_type_by_name(Types.identity_type_name()) :: Msdata.SystEnumItems.t() | nil
  def get_identity_type_by_name(identity_type_name) when is_binary(identity_type_name),
    do: MscmpSystEnums.get_enum_item_by_name("identity_types", identity_type_name)

  @spec get_identity_type_default(Types.identity_type_functional_types() | nil) ::
          Msdata.SystEnumItems.t()
  def get_identity_type_default(nil), do: MscmpSystEnums.get_default_enum_item("identity_types")

  def get_identity_type_default(functional_type) when is_atom(functional_type) do
    MscmpSystEnums.get_default_enum_item("identity_types",
      functional_type_name: Atom.to_string(functional_type)
    )
  end

  @spec set_identity_expiration(Types.identity_id() | Msdata.SystIdentities.t(), DateTime.t()) ::
          {:ok, Msdata.SystIdentities.t()} | {:error, MscmpSystError.t()}
  def set_identity_expiration(identity_id, %DateTime{} = expires_date)
      when is_binary(identity_id) do
    identity_id
    |> get_identity_record()
    |> set_identity_expiration(expires_date)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure setting Identity expiration by ID.",
          cause: error
        }
      }
  end

  def set_identity_expiration(%Msdata.SystIdentities{} = identity, %DateTime{} = expires_date) do
    {:ok, Helpers.update_record(identity, %{identity_expires: expires_date})}
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure setting Identity expiration.",
          cause: error
        }
      }
  end

  @spec clear_identity_expiration(Types.identity_id() | Msdata.SystIdentities.t()) ::
          {:ok, Msdata.SystIdentities.t()} | {:error, MscmpSystError.t()}

  def clear_identity_expiration(identity_id) when is_binary(identity_id) do
    identity_id
    |> get_identity_record()
    |> clear_identity_expiration()
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure clearing Identity expiration by ID.",
          cause: error
        }
      }
  end

  def clear_identity_expiration(%Msdata.SystIdentities{} = identity) do
    {:ok, Helpers.update_record(identity, %{identity_expires: nil})}
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure clearing Identity expiration.",
          cause: error
        }
      }
  end

  @spec identity_expired?(Types.identity_id() | Msdata.SystIdentities.t()) ::
          {:ok, boolean()} | {:error, MscmpSystError.t()}
  def identity_expired?(identity) when is_binary(identity) do
    from(i in Msdata.SystIdentities,
      where: i.id == ^identity,
      select: struct(i, [:identity_expires])
    )
    |> MscmpSystDb.one!()
    |> identity_expired?()
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure testing identity expiration by ID.",
          cause: error
        }
      }
  end

  def identity_expired?(%Msdata.SystIdentities{} = identity) do
    expired =
      if identity.identity_expires == nil,
        do: false,
        else: DateTime.compare(DateTime.utc_now(), identity.identity_expires) == :gt

    {:ok, expired}
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure testing identity expiration.",
          cause: error
        }
      }
  end

  @spec identity_validated?(Types.identity_id() | Msdata.SystIdentities.t()) ::
          {:ok, boolean()} | {:error, MscmpSystError.t()}
  def identity_validated?(identity) when is_binary(identity) do
    from(i in Msdata.SystIdentities,
      where: i.id == ^identity,
      select: struct(i, [:validated])
    )
    |> MscmpSystDb.one!()
    |> identity_validated?()
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure testing identity validated by ID.",
          cause: error
        }
      }
  end

  def identity_validated?(%Msdata.SystIdentities{validated: validated})
      when not is_nil(validated),
      do: {:ok, true}

  def identity_validated?(%Msdata.SystIdentities{}), do: {:ok, false}

  @spec delete_identity(
          Types.identity_id() | Msdata.SystIdentities.t(),
          Types.identity_type_name()
        ) ::
          :deleted | :not_found
  def delete_identity(identity_id, identity_type_name)
      when is_binary(identity_id) and is_binary(identity_type_name) do
    from(i in Msdata.SystIdentities,
      join: ei in assoc(i, :identity_type),
      where: i.id == ^identity_id and ei.internal_name == ^identity_type_name
    )
    |> MscmpSystDb.delete_all()
    |> case do
      {0, _} ->
        :not_found

      {1, _} ->
        :deleted

      error ->
        raise MscmpSystError,
          code: :undefined_error,
          message: "Failure deleting Identity.",
          cause: error
    end
  end

  def delete_identity(%Msdata.SystIdentities{} = identity, identity_type_name),
    do: delete_identity(identity.id, identity_type_name)

  @spec get_identity_record(Types.identity_id()) :: Msdata.SystIdentities.t()
  def get_identity_record(identity_id) when is_binary(identity_id) do
    from(i in Msdata.SystIdentities, where: i.id == ^identity_id)
    |> MscmpSystDb.one!()
  end
end
