# Source File: service.ex
# Location:    musebms/app_server/components/system/mscmp_syst_interaction/lib/runtime/service.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystInteraction.Runtime.Service do
  @moduledoc false

  use GenServer

  alias MscmpSystError.Types, as: ErrorType
  alias MscmpSystInteraction.Impl

  ######
  #
  # This module implements the mechanics of dealing with GenServer runtime
  # concerns.  Business logic should largely/entirely appear elsewhere.
  #
  ######

  ##
  ## Server
  ##

  ##############################################################################
  #
  # init
  #
  #

  @impl true
  @spec init(Keyword.t()) :: {:ok, map()} | {:stop, ErrorType.parsable_error()}
  def init(opts) do
    with context_table <- :ets.new(nil, [:set, :protected]),
         {:ok, _} <- MscmpSystDb.put_datastore_context(opts[:datastore_context_name]),
         :ok <- Impl.Context.refresh_from_database(context_table, opts) do
      {:ok,
       %{
         datastore_context_name: opts[:datastore_context_name],
         context_table_tid: context_table
       }}
    end
  rescue
    error in Postgrex.Error -> {:stop, MscmpSystDb.get_pg_exception(error)}
    error -> {:stop, error}
  end

  ##############################################################################
  #
  # handle_call
  #
  #

  @impl true
  def handle_call(:get_context_table, _from, state),
    do: {:reply, state.context_table_tid, state}

  @impl true
  def handle_call(:get_runtime_config, _from, state) do
    runtime_config = %{
      context_table: state.context_table_tid
    }

    {:reply, runtime_config, state}
  end

  ##############################################################################
  #
  # terminate
  #
  #

  @impl true
  def terminate(:normal, state) do
    :ets.delete(state.context_table_tid)
    :ok
  end
end
