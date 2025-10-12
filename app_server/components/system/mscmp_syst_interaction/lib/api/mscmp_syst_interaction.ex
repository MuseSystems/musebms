# Source File: mscmp_syst_interaction.ex
# Location:    musebms/app_server/components/system/mscmp_syst_interaction/lib/api/mscmp_syst_interaction.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystInteraction do
  @external_resource "README.md"
  @moduledoc Path.join([__DIR__, "..", "..", "README.md"])
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  use MscmpSystService

  alias MscmpSystError.Types.Context, as: ErrorContext
  alias MscmpSystInteraction.Impl
  alias MscmpSystInteraction.Runtime
  alias MscmpSystInteraction.Types

  ##############################################################################
  #
  # Options Definition
  #
  #

  option_defs = [
    datastore_context_name: [
      type:
        {:or,
         [
           nil,
           :atom,
           {:tuple, [{:in, [:via]}, :atom, :any]},
           {:tuple, [{:in, [:global]}, :any]}
         ]},
      type_doc: "`t:GenServer.name/0 or `nil`",
      doc: """
      Specifies the name of the Datastore Context to be used by the Interaction
      Context Service.
      """
    ],
    context_id: [
      type: {:or, [nil, {:custom, Ecto.UUID, :dump, []}]},
      default: nil,
      doc: """
      Limits the action to a specific Interaction Context as identified by its
      record ID.
      """
    ],
    context_name: [
      type: {:or, [nil, :string]},
      default: nil,
      doc: """
      Limits the action to a specific Interaction Context as identified by its
      Internal Name.
      """
    ],
    context_mode: [
      type:
        {:or,
         [
           {:in, [:unlocked, :maintenance]},
           {:tuple, [{:in, [:locked]}, {:or, [{:in, [:system]}, :any]}]}
         ]},
      default: :unlocked,
      type_doc: "`t:MscmpSystInteraction.Types.context_mode/0`",
      type_spec: quote(do: Types.context_mode()),
      doc: """
      Establishes the global locking mode of a given Interaction Context.  This
      may be set for batch updates or maintenance where arbitrary records may be
      accessed and modified.  Modes `:unlocked` and `:maintenance` are both
      "unowned" modes in that they are not associated with a specific user or
      session and has locked the Interaction Context for its own specific
      purposes (such to update records in batch).  The `:locked` mode is a
      "owned" mode that is associated with a specific user or session or uses
      the explicit owner designation of `:system` to indicate that the system
      itself has taken the lock.  Designating the `:locked` mode is done via a
      tuple where the first element is `:locked` and the second element is the
      locking agent.
      """
    ],
    force: [
      type: :boolean,
      default: false,
      doc: """
      Forces the requested change even in cases where it might not otherwise be
      allowed.
      """
    ]
  ]

  ##############################################################################
  #
  # child_spec
  #
  #

  @child_spec_opts NimbleOptions.new!(
                     Keyword.take(option_defs, [
                       :datastore_context_name,
                       :context_mode
                     ]) ++ @service_option_defs
                   )

  @doc section: :service_management
  @doc """
  Returns a child specification for the Interaction Context Service.

  ## Parameters

    * `opts` - A keyword list of options.  See the `Options` section for
      details.

  ## Options

    #{NimbleOptions.docs(@child_spec_opts)}

  ## Examples

      iex> MscmpSystInteraction.child_spec(
      ...>   service_name: MyApp.InteractionContextService,
      ...>   datastore_context_name: MyApp.DatastoreContext)
      %{
        id: MscmpSystInteraction,
        start:
          {MscmpSystInteraction,
           :start_link,
           [[timeout: :infinity, service_name: MyApp.InteractionContextService, datastore_context_name: MyApp.DatastoreContext]]},
      }

  """
  @impl true
  @spec child_spec(Keyword.t()) :: Supervisor.child_spec()
  def child_spec(opts) do
    validated_opts = NimbleOptions.validate!(opts, @child_spec_opts)
    %{id: __MODULE__, start: {MscmpSystInteraction, :start_link, [validated_opts]}}
  end

  ##############################################################################
  #
  # start_link
  #
  #

  @start_link_opts NimbleOptions.new!(
                     Keyword.take(option_defs, [
                       :datastore_context_name,
                       :context_mode
                     ]) ++ @service_option_defs
                   )

  @doc section: :service_management
  @doc """
  Starts an instance of the Interaction Context Service.

  Starting the service establishes the required processes and pre-populates the
  service cache with data from the database.  Most other functions in this
  module require that the service is started prior to use and will fail if the
  service is not started.

  ## Parameters

    * `opts` - Options for the Interaction Context Service. See the Options section below
      for more information.

  ## Options

    #{NimbleOptions.docs(@start_link_opts)}
  """
  @impl true
  @spec start_link(Keyword.t()) :: {:ok, pid()} | :ignore | {:error, Mserror.InteractionError.t()}
  def start_link(opts) do
    validated_opts = NimbleOptions.validate!(opts, @start_link_opts)

    genserver_opts =
      [name: validated_opts[:service_name]] ++
        Keyword.take(validated_opts, [:debug, :timeout, :hibernate_after])

    init_opts = Keyword.take(validated_opts, [:datastore_context_name, :context_mode])

    case GenServer.start_link(Runtime.Service, init_opts, genserver_opts) do
      {:ok, pid} ->
        {:ok, pid}

      {:error, reason} = error ->
        dbg(error)

        {:error,
         Mserror.InteractionError.new(
           :service_management,
           "Error starting Interaction Context Service",
           parse_error: reason,
           context: %ErrorContext{
             origin: {__MODULE__, :start_link, 1},
             parameters: %{opts: validated_opts}
           }
         )}

      :ignore ->
        :ignore
    end
  end

  ##############################################################################
  #
  # put_service
  #
  #

  @doc section: :service_management
  @doc """
  Sets the specific Interaction Context Service instance which the current
  process should use.


  ## Parameters

    * `context_service_name` - the name under which the Interaction Context
      Service is started and by which it may be referenced.  This is any name
      that may be used to reference a GenServer process.  Additionally, this
      value may be set `nil` to clear the currently set Interaction Context
      Service name.

  ## Returns

  Returns the name of the previously set Interaction Context Service name or
  `nil` if no Interaction Context Service name had been previously set.

  ## Examples

    Setting a specific Integration Context Service name:

      iex> MscmpSystInteraction.put_service(:"MscmpSystInteraction.TestSupportService")
      ...> MscmpSystInteraction.get_service()
      :"MscmpSystInteraction.TestSupportService"

    Clearing a previously set specific Service Name:

      iex> MscmpSystInteraction.put_service(nil)
      ...> MscmpSystInteraction.get_service()
      nil
  """
  @impl true
  @spec put_service(Types.service_name()) :: Types.service_name()
  defdelegate put_service(context_service_name), to: Runtime.ProcessUtils

  ##############################################################################
  #
  # get_service
  #
  #

  @doc section: :service_management
  @doc """
  Retrieves the name of the currently set Interaction Context Service instance.

  See `put_service/1` for more information about setting an active Enumeration
  Service name.

  ## Returns

  Returns the name of the currently set Interaction Context Service name or
  `nil` if no Interaction Context Service name has been set.

  ## Examples

    Retrieving a specific Interaction Context Service name:

      iex> MscmpSystInteraction.put_service(:"MscmpSystInteraction.TestSupportService")
      ...> MscmpSystInteraction.get_service()
      :"MscmpSystInteraction.TestSupportService"

    Retrieving a specific Interaction Context Service name when no value is
    currently set for the process:

      iex> MscmpSystInteraction.put_service(nil)
      ...> MscmpSystInteraction.get_service()
      nil
  """
  @impl true
  @spec get_service() :: Types.service_name()
  defdelegate get_service(), to: Runtime.ProcessUtils

  ##############################################################################
  #
  # get_runtime_config
  #
  #

  @doc section: :service_management
  @doc """
  Retrieves the runtime configuration of a previously started Interaction Context Service.

  Some services need a mechanism to return features such as `:ets` table names
  which are set at runtime.  This callback provides the mechanism by which such
  runtime configuration can be returned.
  """
  @impl true
  @spec get_runtime_config() :: map()
  defdelegate get_runtime_config(), to: Runtime.ProcessUtils

  ##############################################################################
  #
  # get_context_config
  #
  #

  @doc section: :context_configuration
  @doc """
  Retrieves the permission configuration for the specified Interaction Context.

  ## Parameters

    * `context_name` - The name of the Interaction Context for which to
      retrieve the permission configuration.  If requested context does not
      exist, an `ArgumentError` exception will be raised.

  ## Returns

  Returns the permission configuration for the specified Interaction Context.
  """
  @spec get_context_config(Types.context_name()) :: Types.ContextConfig.t()
  def get_context_config(context_name) when is_binary(context_name) do
    Impl.Context.get_context_config(context_name)
  end
end
