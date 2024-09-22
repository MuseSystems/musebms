# Source File: helpers.ex
# Location:    musebms/app_server/components/system/mscmp_syst_authn/lib/impl/msdata/helpers.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystAuthn.Impl.Msdata.Helpers do
  @moduledoc false

  alias MscmpSystAuthn.Impl

  # Resolve user provided options to a complete set of options by filling gaps
  # with pre-defined defaults.
  #
  # Allows the changeset function to resolve defaults that are used to
  # parameterize other validations.   We do that resolution in the changeset
  # function directly so we're only doing the user/default resolution once for
  # a changeset.

  ##############################################################################
  #
  # Option Definitions
  #
  #

  @option_defs [
    min_internal_name_length: [
      type: :non_neg_integer,
      default: 6,
      doc: "Minimum length for internal names"
    ],
    max_internal_name_length: [
      type: :pos_integer,
      default: 64,
      doc: "Maximum length for internal names"
    ],
    min_display_name_length: [
      type: :non_neg_integer,
      default: 6,
      doc: "Minimum length for display names"
    ],
    max_display_name_length: [
      type: :pos_integer,
      default: 64,
      doc: "Maximum length for display names"
    ]
  ]

  ##############################################################################
  #
  # validator_options
  #
  #

  @spec validator_options(list(atom())) :: Macro.t()
  defmacro validator_options(option_names) do
    wanted_opts = Keyword.take(@option_defs, option_names)

    quote do
      unquote(Macro.escape(NimbleOptions.new!(wanted_opts)))
    end
  end

  @spec resolve_access_account_id(term()) :: term()
  def resolve_access_account_id(%{access_account_name: access_account_name} = change_params)
      when is_binary(access_account_name) do
    {:ok, access_account_id} =
      Impl.AccessAccount.get_access_account_id_by_name(access_account_name)

    Map.put(change_params, :access_account_id, access_account_id)
  end

  def resolve_access_account_id(change_params), do: change_params

  @spec resolve_owner_id(term()) :: term()
  def resolve_owner_id(%{owning_owner_name: owner_name} = access_account_params)
      when is_binary(owner_name) do
    owner_id =
      owner_name
      |> MscmpSystInstance.get_owner_id_by_name()
      |> process_owner_id_by_name_result()

    Map.put(access_account_params, :owning_owner_id, owner_id)
  end

  def resolve_owner_id(access_account_params), do: access_account_params

  defp process_owner_id_by_name_result({:ok, owner_id}), do: owner_id

  defp process_owner_id_by_name_result(error) do
    raise MscmpSystError,
      code: :undefined_error,
      message: "Failure resolving Owning Owner ID from Owner Name",
      cause: error
  end

  @spec resolve_instance_id(term()) :: term()
  def resolve_instance_id(%{instance_name: instance_name} = change_params)
      when is_binary(instance_name) do
    {:ok, instance_id} = MscmpSystInstance.get_instance_id_by_name(instance_name)

    Map.put(change_params, :instance_id, instance_id)
  end

  def resolve_instance_id(change_params), do: change_params

  @spec resolve_network_rule_params_func_type(term()) :: term()
  def resolve_network_rule_params_func_type(%{functional_type: type} = params)
      when is_atom(type),
      do: Map.put(params, :functional_type, Atom.to_string(params[:functional_type]))

  def resolve_network_rule_params_func_type(params), do: params

  @spec resolve_credential_type_id(map(), any()) :: map()
  def resolve_credential_type_id(
        %{credential_type_name: credential_type_name} = change_params,
        _operation
      )
      when is_binary(credential_type_name) do
    credential_type =
      MscmpSystEnums.get_item_by_name("credential_types", credential_type_name)

    Map.put(change_params, :credential_type_id, credential_type.id)
  end

  def resolve_credential_type_id(
        %{credential_type_id: credential_type_id} = change_params,
        _operation
      )
      when is_binary(credential_type_id) do
    change_params
  end

  # TODO: Should we really be defaulting a credential type value?  Is such
  #       defaulting valid?

  @spec resolve_credential_type_id(any()) :: any()
  def resolve_credential_type_id(change_params, :insert) do
    credential_type = MscmpSystEnums.get_default_item("credential_types")

    Map.put(change_params, :credential_type_id, credential_type.id)
  end

  def resolve_credential_type_id(change_params), do: change_params
end
