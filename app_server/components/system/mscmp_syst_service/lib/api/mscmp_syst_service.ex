# Source File: mscmp_syst_service.ex
# Location:    musebms/app_server/components/system/mscmp_syst_service/lib/api/mscmp_syst_service.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystService do
  @external_resource "README.md"
  @moduledoc Path.join([__DIR__, "..", "..", "README.md"])
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  alias MscmpSystService.Types

  # ==============================================================================================
  # ==============================================================================================
  #
  # Service Management
  #
  # ==============================================================================================
  # ==============================================================================================

  ##############################################################################
  #
  # child_spec
  #
  #

  @doc """
  Returns the child specification of the service.

  ## Parameters

  * `opts` - A service may define one or more options which govern the startup
  behavior of the service.  Options are specific to Service and may be required
  or optional depending on the needs of the Service.
  """
  @callback child_spec(opts :: Keyword.t()) :: Supervisor.child_spec()

  ##############################################################################
  #
  # start_link
  #
  #

  @doc """
  Starts the Service instance.

  This function should start the underlying GenServer process and return the
  appropriate result tuple.

  > #### `MscmpSystError` Exceptions {: .info}
  >
  > Typically exceptions passed from an implementing service will be `Exception`
  > objects which are specifically compatible with `MscmpSystError` exceptions.
  > Such exceptions are defined by the service implementing module as `Mserror`
  > Exception specializations.

  ## Parameters

    * `opts` - Services may define either required or optional parameters which
    govern its startup process.
  """
  @callback start_link(opts :: Keyword.t()) ::
              {:ok, pid()} | :ignore | {:error, Exception.t()}

  @doc """
  Establishes a specific running instance of the Service as the current service
  for the running process which invoked this function.


  ## Parameters

    * `service_name` - the name under which the Service is started and by which
    it may be referenced.  This is any name that may be used to reference a
    GenServer process.  Additionally, this value may be set `nil` to clear the
    currently set Service name.

  ## Returns

  Returns the name of the previously set Service or `nil` if no Service name had
  been previously set.

  """
  @callback put_service(Types.service_name()) :: Types.service_name()

  @doc """
  Retrieves the name of the currently set Service instance.

  See `put_service/1` for more information about setting an active Service name.

  ## Returns

  Returns the name of the currently set Service name or `nil` if no Service name
  has been set.
  """
  @callback get_service() :: Types.service_name()

  @doc """
  Retrieves the runtime configuration of a previously started Service.

  Some services need a mechanism to return features such as `:ets` table names
  which are set at runtime.  This callback provides the mechanism by which such
  runtime configuration can be returned.
  """
  @callback get_runtime_config() :: map()

  @spec __using__(term()) :: Macro.t()
  defmacro __using__(_opts) do
    quote do
      @behaviour MscmpSystService

      @service_option_defs [
        debug: [
          type: :boolean,
          doc: """
          If true, the GenServer backing the Service will be started in debug mode.
          """
        ],
        timeout: [
          type: :timeout,
          default: :infinity,
          doc: "Timeout value for the start_link call."
        ],
        hibernate_after: [
          type: :timeout,
          doc: """
          If present, the GenServer process awaits any message for the specified
          time before hibernating.  The timeout value is expressed in milliseconds.
          """
        ],
        service_name: [
          type:
            {:or,
             [
               nil,
               :atom,
               {:tuple, [{:in, [:via]}, :atom, :any]},
               {:tuple, [{:in, [:global]}, :any]}
             ]},
          required: true,
          type_doc: "`t:GenServer.name/0 or `nil`",
          doc: """
          The name to use for the GenServer backing this specific Service instance.
          """
        ]
      ]

      @service_option_selections [:debug, :timeout, :hibernate_after, :service_name]
    end
  end
end
