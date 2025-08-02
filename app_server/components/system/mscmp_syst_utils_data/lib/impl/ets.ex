# Source File: ets.ex
# Location:    musebms/app_server/components/system/mscmp_syst_utils_data/lib/impl/ets.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystUtilsData.Impl.Ets do
  @moduledoc false

  ##############################################################################
  #
  # ets_insert
  #
  #

  @spec ets_insert(:ets.table(), term()) :: :ok | {:error, term()}
  def ets_insert(table, data) do
    :ets.insert(table, data)
    :ok
  rescue
    error -> {:error, {:ets_error, error}}
  end

  ##############################################################################
  #
  # ets_lookup_element
  #
  #

  @spec ets_lookup_element(:ets.table(), term(), non_neg_integer()) ::
          {:ok, term()} | {:error, term()}
  def ets_lookup_element(table, key, element_index) do
    {:ok, :ets.lookup_element(table, key, element_index)}
  rescue
    error -> {:error, {:ets_error, error}}
  end

  ##############################################################################
  #
  # ets_update_element
  #
  #

  @spec ets_update_element(:ets.table(), term(), term()) :: :ok | {:error, term()}
  def ets_update_element(table, key, updated_data) do
    true = :ets.update_element(table, key, updated_data)
    :ok
  rescue
    error -> {:error, {:ets_error, error}}
  end

  ##############################################################################
  #
  # ets_delete
  #
  #

  @spec ets_delete(:ets.table(), term()) :: :ok | {:error, term()}
  def ets_delete(table, key) do
    true = :ets.delete(table, key)
    :ok
  rescue
    error -> {:error, {:ets_delete_error, error}}
  end
end
