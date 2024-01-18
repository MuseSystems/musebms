# Source File: dev_support.ex
# Location:    musebms/app_server/components/system/mscmp_syst_settings/lib/runtime/dev_support.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystSettings.Runtime.DevSupport do
  @moduledoc false

  @spec get_devsupport_service_name() :: atom()
  def get_devsupport_service_name, do: :settings_dev_service

  @spec get_testsupport_service_name() :: atom()
  def get_testsupport_service_name, do: :settings_test_service

  @spec start_support_services(keyword()) ::
          :ignore | {:error, any()} | {:ok, pid()} | {:ok, pid(), any()}
  def start_support_services(opts) do
    opts =
      MscmpSystUtils.resolve_options(opts,
        childspec_id: __MODULE__,
        supervisor_name: MscmpSystSettings.DevSupportSupervisor,
        service_name: get_devsupport_service_name(),
        datastore_context: MscmpSystDb.get_devsupport_context_name()
      )

    settings_service_spec = %{
      id: opts[:childspec_id],
      start: {MscmpSystSettings, :start_link, [{opts[:service_name], opts[:datastore_context]}]}
    }

    children = [{DynamicSupervisor, strategy: :one_for_one, name: opts[:supervisor_name]}]

    Supervisor.start_link(children, strategy: :one_for_one)
    Logger.configure(level: :info)
    ExUnit.start()

    DynamicSupervisor.start_child(opts[:supervisor_name], settings_service_spec)
  end

  @spec start_testsupport_services(keyword()) ::
          :ignore | {:error, any()} | {:ok, pid()} | {:ok, pid(), any()}
  def start_testsupport_services(opts) do
    opts =
      MscmpSystUtils.resolve_options(opts,
        supervisor_name: MscmpSystSettings.TestSupportSupervisor,
        service_name: get_testsupport_service_name(),
        datastore_context: MscmpSystDb.get_testsupport_context_name()
      )

    start_support_services(opts)
  end
end