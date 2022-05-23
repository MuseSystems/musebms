# Source File: instances.ex
# Location:    components/system/msbms_syst_instance_mgr/lib/impl/instances.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystInstanceMgr.Impl.Instances do
  import Ecto.Query

  alias MsbmsSystInstanceMgr.Data
  alias MsbmsSystInstanceMgr.Types

  require Logger

  @context_code_length 32
  @instance_code_length 32
  @context_name_prefix "msbms"

  @moduledoc false

  ######
  #
  # Logic for managing and accessing SystInstances data and supporting data.
  #
  ######

  @spec list_instances(
          Keyword.t(
            instance_types: list(Types.instance_type_name()) | [],
            instance_state_functional_types: list(Types.instance_state_functional_types()) | [],
            owner_id: Ecto.UUID.t() | nil,
            owner_state_functional_types: list(Types.owner_state_functional_types()) | [],
            applications: list(Types.application_name()) | [],
            sort: list(:application | :owner | :instance)
          )
        ) ::
          {:ok, list(Types.instances_list_item())} | {:error, MsbmsSystError.t()}
  def list_instances(opts_given) do
    opts_default = [
      instance_types: [],
      instance_state_functional_types: [],
      owner_id: nil,
      owner_state_functional_types: [],
      applications: [],
      sort: []
    ]

    opts = Keyword.merge(opts_given, opts_default, fn _k, v1, _v2 -> v1 end)

    from(i in Data.SystInstances,
      join: it in assoc(i, :instance_type),
      as: :instance_type,
      join: itft in assoc(it, :functional_type),
      as: :instance_type_functional_type,
      join: is in assoc(i, :instance_state),
      as: :instance_state,
      join: isft in assoc(is, :functional_type),
      as: :instance_state_functional_type,
      join: o in assoc(i, :owner),
      as: :owner,
      join: os in assoc(o, :owner_state),
      as: :owner_state,
      join: oft in assoc(os, :functional_type),
      as: :owner_state_functional_type,
      join: a in assoc(i, :application),
      as: :application,
      select: %{
        instance_id: i.id,
        instance_internal_name: i.internal_name,
        instance_display_name: i.display_name,
        instance_owning_instance_id: i.owning_instance_id,
        instance_options: i.instance_options,
        instance_type_id: it.id,
        instance_type_display_name: it.display_name,
        instance_type_external_name: it.external_name,
        instance_type_functional_type_id: itft.id,
        instance_type_functional_type_name: itft.internal_name,
        instance_state_id: is.id,
        instance_state_display_name: is.display_name,
        instance_state_external_name: is.external_name,
        instance_state_functional_type_id: isft.id,
        instance_state_functional_type_name: isft.internal_name,
        owner_id: o.id,
        owner_display_name: o.display_name,
        owner_state_display_name: os.display_name,
        owner_state_functional_type_name: oft.internal_name,
        owner_state_functional_type_display_name: oft.display_name,
        application_id: a.id,
        application_display_name: a.display_name,
        application_syst_description: a.syst_description
      }
    )
    |> maybe_add_instance_type_filter(opts[:instance_types])
    |> maybe_add_instance_state_filter(opts[:instance_state_functional_types])
    |> maybe_add_owner_state_filter(opts[:owner_state_functional_types])
    |> maybe_add_owner_filter(opts[:owner_id])
    |> maybe_add_application_filter(opts[:applications])
    |> maybe_add_instance_display_name_sorts(opts[:sort])
    |> MsbmsSystDatastore.all()
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure retrieving instances list.",
          cause: error
        }
      }
  end

  defp maybe_add_instance_type_filter(query, [_ | _] = instance_types) do
    from([instance_type: f] in query, where: f.internal_name in ^instance_types)
  end

  defp maybe_add_instance_type_filter(query, _instance_types), do: query

  defp maybe_add_instance_state_filter(query, [_ | _] = functional_types) do
    functional_types
    |> Enum.map(&Atom.to_string/1)
    |> then(&from([instance_type: f] in query, where: f.internal_name in ^&1))
  end

  defp maybe_add_instance_state_filter(query, _functional_types), do: query

  defp maybe_add_owner_filter(query, owner_id) when is_binary(owner_id) do
    from([owner: o] in query, where: o.id == ^owner_id)
  end

  defp maybe_add_owner_filter(query, _owner_id), do: query

  defp maybe_add_owner_state_filter(query, [_ | _] = functional_types) do
    functional_types
    |> Enum.map(&Atom.to_string/1)
    |> then(&from([owner_state_functional_type: f] in query, where: f.internal_name in ^&1))
  end

  defp maybe_add_owner_state_filter(query, _functional_types), do: query

  defp maybe_add_application_filter(query, [_ | _] = applications) do
    from([application: a] in query, where: a.internal_name in ^applications)
  end

  defp maybe_add_application_filter(query, _applications), do: query

  defp maybe_add_instance_display_name_sorts(query, sorts) do
    Enum.reduce(sorts, query, fn sort, qry -> add_instance_sort(qry, sort) end)
  end

  defp add_instance_sort(query, :application) do
    from([application: a] in query, order_by: a.display_name)
  end

  defp add_instance_sort(query, :owner) do
    from([owner: o] in query, order_by: o.display_name)
  end

  defp add_instance_sort(query, :instance) do
    from([i] in query, order_by: i.display_name)
  end

  @spec get_instance_by_name(Types.instance_name()) ::
          {:ok, Data.SystInstances.t()} | {:error, MsbmsSystError.t()}
  def get_instance_by_name(instance_internal_name) do
    child_instance_qry =
      from(i in Data.SystInstances,
        join: ia in assoc(i, :application),
        join: it in assoc(i, :instance_type),
        join: is in assoc(i, :instance_state),
        join: isft in assoc(is, :functional_type),
        preload: [
          application: ia,
          instance_type: it,
          instance_state: {is, functional_type: isft}
        ]
      )

    from(i in Data.SystInstances,
      join: ia in assoc(i, :application),
      join: it in assoc(i, :instance_type),
      join: is in assoc(i, :instance_state),
      join: isft in assoc(is, :functional_type),
      join: io in assoc(i, :owner),
      left_join: oi in assoc(i, :owning_instance),
      where: i.internal_name == ^instance_internal_name,
      preload: [
        application: ia,
        instance_type: it,
        instance_state: {is, functional_type: isft},
        owner: io,
        owning_instance: oi,
        owned_instances: ^child_instance_qry
      ]
    )
    |> MsbmsSystDatastore.one!()
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure retrieving instance record.",
          cause: error
        }
      }
  end

  # TODO: I'm not over-fond of the depth of private function nesting that's
  # supporting the create_instance/1 function.  Right now get it working, but
  # revisit once we're off critical path.
  @spec create_instance(Types.instance_params()) ::
          {:ok, Data.SystInstances.t()} | {:error, MsbmsSystError.t()}
  def create_instance(instance_params) do
    resolved_instance_params =
      instance_params
      |> resolve_application()
      |> resolve_instance_type()
      |> resolve_instance_state()
      |> resolve_owner()
      |> resolve_owning_instance()
      |> resolve_instance_options()

    %Data.SystInstances{}
    |> Data.SystInstances.changeset(resolved_instance_params)
    |> MsbmsSystDatastore.insert!(returning: true)
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure creating instance record.",
          cause: error
        }
      }
  end

  @spec set_instance_values(Types.instance_name(), Types.instance_params()) ::
          {:ok, Data.SystInstances.t()} | {:error, MsbmsSystError.t()}
  def set_instance_values(instance_name, instance_params) do
    # TODO: Consider raising on unsupported parameters rather than ignoring
    #       them.
    resolved_instance_params =
      instance_params
      |> resolve_application()
      |> resolve_instance_type_no_default()
      |> resolve_instance_state_no_default()
      |> resolve_instance_options()
      |> Map.delete(:owner_id)
      |> Map.delete(:owner_name)
      |> Map.delete(:owning_instance_id)
      |> Map.delete(:owning_instance_name)

    from(i in Data.SystInstances, where: [internal_name: ^instance_name])
    |> MsbmsSystDatastore.one!()
    |> Data.SystInstances.changeset(resolved_instance_params)
    |> MsbmsSystDatastore.update!(returning: true)
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure setting instance record values.",
          cause: error
        }
      }
  end

  defp resolve_instance_type_no_default(
         %{instance_type_name: instance_type_name} = instance_params
       )
       when is_binary(instance_type_name),
       do: resolve_instance_type(instance_params)

  defp resolve_instance_type_no_default(instance_params), do: instance_params

  defp resolve_instance_state_no_default(
         %{instance_state_name: instance_state_name} = instance_params
       )
       when is_binary(instance_state_name),
       do: resolve_instance_state(instance_params)

  defp resolve_instance_state_no_default(instance_params), do: instance_params

  defp resolve_application(%{application_name: application_name} = instance_params)
       when is_binary(application_name) do
    application =
      from(a in Data.SystApplications,
        where: a.internal_name == ^application_name,
        select: [:id]
      )
      |> MsbmsSystDatastore.one!()

    Map.put(instance_params, :application_id, application.id)
  end

  defp resolve_application(instance_params), do: instance_params

  defp resolve_instance_type(%{instance_type_id: instance_type_id} = instance_params)
       when is_binary(instance_type_id),
       do: instance_params

  defp resolve_instance_type(%{instance_type_name: instance_type_name} = instance_params)
       when is_binary(instance_type_name) do
    instance_type = MsbmsSystEnums.get_enum_item_by_name("instance_types", instance_type_name)
    Map.put(instance_params, :instance_type_id, instance_type.id)
  end

  defp resolve_instance_type(instance_params) do
    instance_type = MsbmsSystEnums.get_default_enum_item("instance_types")
    Map.put(instance_params, :instance_type_id, instance_type.id)
  end

  defp resolve_instance_state(%{instance_state_id: instance_state_id} = instance_params)
       when is_binary(instance_state_id),
       do: instance_params

  defp resolve_instance_state(%{instance_state_name: instance_state_name} = instance_params)
       when is_binary(instance_state_name) do
    instance_state = MsbmsSystEnums.get_enum_item_by_name("instance_states", instance_state_name)
    Map.put(instance_params, :instance_state_id, instance_state.id)
  end

  defp resolve_instance_state(instance_params) do
    instance_state = MsbmsSystEnums.get_default_enum_item("instance_states")
    Map.put(instance_params, :instance_state_id, instance_state.id)
  end

  defp resolve_owner(%{owner_name: owner_name} = instance_params)
       when is_binary(owner_name) do
    owner =
      from(o in Data.SystOwners,
        where: o.internal_name == ^owner_name,
        select: [:id]
      )
      |> MsbmsSystDatastore.one!()

    Map.put(instance_params, :owner_id, owner.id)
  end

  defp resolve_owner(instance_params), do: instance_params

  defp resolve_owning_instance(%{owning_instance_name: owning_instance_name} = instance_params)
       when is_binary(owning_instance_name) do
    owning_instance =
      from(i in Data.SystInstances,
        where: i.internal_name == ^owning_instance_name,
        select: [:id]
      )
      |> MsbmsSystDatastore.one!()

    Map.put(instance_params, :owning_instance_id, owning_instance.id)
  end

  defp resolve_owning_instance(instance_params), do: instance_params

  defp resolve_instance_options(instance_params) do
    instance_type =
      MsbmsSystEnums.get_enum_item_by_id("instance_types", instance_params.instance_type_id)

    default_instance_options = instance_type.user_options || instance_type.syst_options

    resolved_instance_options =
      Map.get(instance_params, :instance_options, %{})
      |> Map.put_new(
        "instance_code",
        Base.encode64(:crypto.strong_rand_bytes(@instance_code_length))
      )
      |> Map.put_new("dbserver_name", default_instance_options["dbserver_name"])
      |> Map.put_new("datastore_contexts", default_instance_options["datastore_contexts"])
      |> resolve_datastore_context_options(
        instance_params,
        default_instance_options["datastore_contexts"]
      )

    Map.put(instance_params, :instance_options, resolved_instance_options)
  end

  defp resolve_datastore_context_options(
         provided_instance_options,
         instance_params,
         default_contexts
       ) do
    provided_contexts = Map.get(provided_instance_options, "datastore_contexts", [])

    provided_contexts
    |> maybe_apply_context_defaults(instance_params.internal_name, default_contexts)
    |> maybe_apply_extended_contexts(provided_contexts)
    |> then(&Map.put(provided_instance_options, "datastore_contexts", &1))
  end

  defp maybe_apply_context_defaults(provided_contexts, instance_name, default_contexts) do
    default_func = fn context, resolved_contexts ->
      curr_instance_context =
        Enum.find(
          provided_contexts,
          %{},
          &(&1["application_context"] == context["application_context"])
        )
        |> Map.put_new(
          "id",
          generate_instance_context_id(instance_name, context["application_context"])
        )
        |> Map.put_new("application_context", context["application_context"])
        |> Map.put_new("db_pool_size", context["db_pool_size"])
        |> Map.put_new(
          "context_code",
          Base.encode64(:crypto.strong_rand_bytes(@context_code_length))
        )

      [curr_instance_context | resolved_contexts]
    end

    Enum.reduce(default_contexts, [], default_func)
  end

  defp maybe_apply_extended_contexts(defaulted_contexts, provided_contexts) do
    eval_func = fn context, resolved_contexts ->
      if is_nil(
           Enum.find(
             defaulted_contexts,
             nil,
             &(&1["application_context"] == context["application_context"])
           )
         ) do
        [context | resolved_contexts]
      else
        resolved_contexts
      end
    end

    Enum.reduce(provided_contexts, defaulted_contexts, eval_func)
  end

  defp generate_instance_context_id(instance_name, application_context, opts_given \\ []) do
    opts_default = [context_name_prefix: @context_name_prefix]

    opts = Keyword.merge(opts_given, opts_default, fn _k, v1, _v2 -> v1 end)

    [opts[:context_name_prefix], instance_name, to_string(application_context)]
    |> Enum.join("_")
  end
end
