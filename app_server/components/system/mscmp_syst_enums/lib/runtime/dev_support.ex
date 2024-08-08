# Source File: dev_support.ex
# Location:    musebms/app_server/components/system/mscmp_syst_enums/lib/runtime/dev_support.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystEnums.Runtime.DevSupport do
  @moduledoc false

  @default_dev_service_name :"MscmpSystEnums.DevSupportService"
  @default_test_service_name :"MscmpSystEnums.TestSupportService"

  devsupport_opts = [
    childspec_id: [
      type: :atom,
      default: __MODULE__,
      doc: """
      Provides the means to override the default childspec id, though typically
      this is not necessary.
      """
    ],
    service_name: [
      type: :atom,
      default: @default_dev_service_name,
      doc: """
      The name to use for the GenServer backing this specific Enumerations
      Service instance.
      """
    ],
    supervisor_name: [
      type: :atom,
      default: :"MscmpSystEnums.DevSupportSupervisor",
      doc: """
      DevSupport services are expected to be started under a Supervisor.  This
      option provides the name of the Supervisor to use.  If the Supervisor does
      not exist, a new Supervisor will be started with the given name.
      """
    ],
    datastore_context_name: [
      type:
        {:or,
         [nil, :atom, {:tuple, [{:in, [:via]}, :atom, :any]}, {:tuple, [{:in, [:global]}, :any]}]},
      type_doc: "`t:GenServer.name/0 or `nil`",
      default: MscmpSystDb.get_devsupport_context_name(),
      doc: """
      The name of the Datastore Context which will back the started instance of
      the Enumerations Service.
      """
    ]
  ]

  @devsupport_opts NimbleOptions.new!(devsupport_opts)
  @devsupport_stop_opts NimbleOptions.new!(Keyword.take(devsupport_opts, [:supervisor_name]))

  @spec get_devsupport_opts_docs() :: String.t()
  def get_devsupport_opts_docs, do: NimbleOptions.docs(@devsupport_opts)

  @spec get_devsupport_stop_opts_docs() :: String.t()
  def get_devsupport_stop_opts_docs, do: NimbleOptions.docs(@devsupport_stop_opts)

  testsupport_opts = [
    childspec_id: [
      type: :atom,
      default: __MODULE__,
      doc: """
      Provides the means to override the default childspec id, though typically
      this is not necessary.
      """
    ],
    service_name: [
      type: :atom,
      default: @default_test_service_name,
      doc: """
      The name to use for the GenServer backing this specific Enumerations Service
      instance.
      """
    ],
    supervisor_name: [
      type: :atom,
      default: :"MscmpSystEnums.TestSupportSupervisor",
      doc: """
      DevSupport services are expected to be started under a Supervisor.  This
      option provides the name of the Supervisor to use.  If the Supervisor does
      not exist, a new Supervisor will be started with the given name.
      """
    ],
    datastore_context_name: [
      type:
        {:or,
         [nil, :atom, {:tuple, [{:in, [:via]}, :atom, :any]}, {:tuple, [{:in, [:global]}, :any]}]},
      type_doc: "`t:GenServer.name/0 or `nil`",
      default: MscmpSystDb.get_testsupport_context_name(),
      doc: """
      The name of the Datastore Context which will back the started instance of
      the Enumerations Service.
      """
    ]
  ]

  @testsupport_opts NimbleOptions.new!(testsupport_opts)
  @testsupport_stop_opts NimbleOptions.new!(Keyword.take(testsupport_opts, [:supervisor_name]))

  @spec get_testsupport_opts_docs() :: String.t()
  def get_testsupport_opts_docs, do: NimbleOptions.docs(@testsupport_opts)

  @spec get_testsupport_stop_opts_docs() :: String.t()
  def get_testsupport_stop_opts_docs, do: NimbleOptions.docs(@testsupport_stop_opts)

  @spec get_devsupport_service_name() :: atom()
  def get_devsupport_service_name, do: @default_dev_service_name

  @spec get_testsupport_service_name() :: atom()
  def get_testsupport_service_name, do: @default_test_service_name

  @spec start_support_services(keyword()) :: :ok
  def start_support_services(opts) do
    opts =
      NimbleOptions.validate!(opts, @devsupport_opts)

    enums_service_spec =
      %{
        id: opts[:childspec_id],
        start:
          {MscmpSystEnums, :start_link, [opts[:service_name], opts[:datastore_context_name], []]}
      }

    _ =
      case Process.whereis(opts[:supervisor_name]) do
        nil ->
          Supervisor.start_link([enums_service_spec],
            name: opts[:supervisor_name],
            strategy: :one_for_one
          )

        supervisor_name ->
          Supervisor.start_child(supervisor_name, enums_service_spec)
      end

    Logger.configure(level: :info)
    ExUnit.start()
  end

  @spec start_testsupport_services(keyword()) :: :ok
  def start_testsupport_services(opts) do
    opts = NimbleOptions.validate!(opts, @testsupport_opts)

    start_support_services(opts)
  end

  @spec stop_support_services(keyword()) :: :ok
  def stop_support_services(opts) do
    opts =
      NimbleOptions.validate!(opts, @devsupport_stop_opts)

    Supervisor.stop(opts[:supervisor_name])
  end

  @spec stop_testsupport_services(keyword()) :: :ok
  def stop_testsupport_services(opts) do
    opts = NimbleOptions.validate!(opts, @testsupport_stop_opts)
    stop_support_services(opts)
  end
end
