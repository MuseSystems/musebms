# Source File: context.ex
# Location:    musebms/app_server/components/system/mscmp_syst_interaction/lib/impl/context.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystInteraction.Impl.Context do
  @moduledoc false

  use Msutils.Guards

  alias MscmpSystError.Types, as: ErrorType
  alias MscmpSystInteraction.Runtime.ProcessUtils
  alias MscmpSystInteraction.Types

  #
  # Config Management
  #

  ##############################################################################
  #
  # refresh_from_database
  #
  #

  @spec refresh_from_database(Keyword.t()) :: :ok
  def refresh_from_database(opts),
    do: ProcessUtils.get_context_table() |> refresh_from_database(opts)

  @spec refresh_from_database(:ets.table(), Keyword.t()) :: :ok
  def refresh_from_database(context_table, opts) do
    with context_configs <- get_db_context_configs(opts),
         true <- :ets.delete_all_objects(context_table),
         true <- :ets.insert(context_table, context_configs) do
      :ok
    else
      error ->
        raise RuntimeError,
              "Failed to refresh all Interaction Context from database: #{inspect(error)}"
    end
  end

  ##############################################################################
  #
  # refresh_context_from_database
  #
  #

  @spec refresh_context_from_database(Types.context_name()) :: :ok
  def refresh_context_from_database(context_name),
    do: ProcessUtils.get_context_table() |> refresh_context_from_database(context_name)

  @spec refresh_context_from_database(:ets.table(), Types.context_name()) :: :ok
  def refresh_context_from_database(context_table, context_name) do
    with context_configs <- get_db_context_configs(context_name: context_name),
         true <- :ets.insert(context_table, context_configs) do
      :ok
    else
      error ->
        raise RuntimeError,
              "Failed to refresh Interaction Context from database: #{inspect(error)}"
    end
  end

  ##############################################################################
  #
  # get_context_config
  #
  #

  @spec get_context_config(Types.context_name()) :: MscmpSystInteraction.Types.ContextConfig.t()
  def get_context_config(context_name),
    do: ProcessUtils.get_context_table() |> get_context_config(context_name)

  @spec get_context_config(atom(), Types.context_name()) :: Types.ContextConfig.t()
  def get_context_config(context_table, context_name),
    do: :ets.lookup_element(context_table, context_name, 3)

  defp get_db_context_configs(opts) do
    result =
      MscmpSystDb.query_for_many!("SELECT * FROM ms_syst.get_interaction_context_perms($1, $2)", [
        opts[:context_id],
        opts[:context_name]
      ])

    Enum.reduce(result.rows, [], fn row, acc -> [parse_db_context_perms_row(row, opts) | acc] end)
  end

  defp parse_db_context_perms_row(
         [context_name, context_perm, context_perms_req, actions, fields],
         opts
       ) do
    reducer = fn {k, v}, acc ->
      Map.put(acc, k, %Types.ContextMember{
        specific_perm: v["specific_perm"],
        categorical_perm: v["categorical_perm"]
      })
    end

    resolved_actions = Enum.reduce(actions, %{}, &reducer.(&1, &2))
    resolved_fields = Enum.reduce(fields, %{}, &reducer.(&1, &2))

    resolved_context = %Types.ContextConfig{
      name: context_name,
      perm: context_perm,
      required_perms: context_perms_req,
      actions: resolved_actions,
      fields: resolved_fields
    }

    {context_name, opts[:context_mode], resolved_context}
  end

  ##############################################################################
  #
  # get_context_mode
  #
  #

  @spec get_context_mode(Types.context_name()) :: Types.context_mode()
  def get_context_mode(context_name),
    do: ProcessUtils.get_context_table() |> get_context_mode(context_name)

  @spec get_context_mode(:ets.table(), Types.context_name()) :: Types.context_mode()
  def get_context_mode(context_table, context_name),
    do: :ets.lookup_element(context_table, context_name, 2)

  ##############################################################################
  #
  # set_all_runtime_modes
  #
  #

  @spec set_all_runtime_modes(Keyword.t()) :: :ok | ErrorType.parsable_error()
  def set_all_runtime_modes(opts) do
    context_table = ProcessUtils.get_context_table()

    insert_result =
      if opts[:force] or global_runtime_change_allowed?() do
        context_table
        |> :ets.select([{{:"$1", :_}, [], [:"$1"]}])
        |> Enum.map(&{&1, opts[:context_mode], opts[:context_locking_agent], nil, nil})
        |> then(&:ets.insert(context_table, &1))
      end

    case insert_result do
      true ->
        :ok

      _ ->
        {:error,
         {:global_mode_change_failure,
          "Failed to globally set Interaction Context runtime modes."}}
    end
  end

  ##############################################################################
  #
  # global_runtime_change_allowed?
  #
  #

  @spec global_runtime_change_allowed?() :: boolean()
  def global_runtime_change_allowed? do
    context_table = ProcessUtils.get_context_table()

    match_specs = [
      {
        {:_, :"$2", :_},
        [{:or, {:==, :locked, {:element, 1, :"$2"}}, {:==, :maintenance, :"$2"}}],
        [true]
      }
    ]

    :ets.select_count(context_table, match_specs) == 0
  end
end
