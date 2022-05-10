defmodule MsbmsSystInstanceMgr do
  alias MsbmsSystInstanceMgr.Data
  alias MsbmsSystInstanceMgr.Impl
  alias MsbmsSystInstanceMgr.Types

  @moduledoc """
  Functionality allowing for the management of application Instances.

  "Instances" are instances of running application environments.  Instances are
  established to host the application for different purposes, such as for
  running the application for production, training, and testing purposes; or as
  a means to implement multi-tenancy where each tenant application environment
  is an Instance.
  """

  @doc """
  Returns a simple list of applications sorted according to the database
  collation.

  ## Examples

      iex> {:ok, _apps} = MsbmsSystInstanceMgr.list_applications()
  """
  @spec list_applications() :: {:ok, list()} | {:error, MsbmsSystError.t()}
  defdelegate list_applications, to: Impl.Applications

  @doc """
  Returns a simple list of owners with optional filtering by owner status and
  sorting.

  ## Options

    * `owner_state_functional_types` - a list of one or more owner state
      functional types with which to filter the list of returned SystOwners
      records.  If this parameter is not provided, then all owners defined in
      the system will be returned.

    * `sort` - A boolean value that, if true, will cause the list of SystOwner
      records to be sorted by the record's Display Name field.  Sorting is done
      by the database and will follow database collation rules for the sort.

  ## Examples

      iex> {:ok, [_ | _]} = MsbmsSystInstanceMgr.list_owners()

      iex> {:ok, [_ | _]} =
      ...>   MsbmsSystInstanceMgr.list_owners(
      ...>     owner_state_functional_types: [:owner_states_active]
      ...>   )
  """
  @spec list_owners(
          Keyword.t(
            owner_state_functional_types: list(Types.owner_state_functional_types()) | [],
            sort: boolean()
          )
          | []
        ) ::
          {:ok, list(Data.SystOwners.t())} | {:error, MsbmsSystError.t()}
  defdelegate list_owners(opts \\ []),
    to: Impl.Owners

  @doc """
  Creates a new `MsbmsSystInstanceMgr.Data.SystOwners` record in the system.

  ## Parameters

    * `owner_name` - a unique key used in programmatic contexts to identify the
      owner record.

    * `owner_display_name` - sets the name of the SystOwners record for the
      purposes of display to users in UIs and reporting.  This value is required
      to be unique across all SystOwners records.

    * `owner_state_id` - sets initial life-cycle state of the SystOwners record.
      This value must be that of an existing
      `t:MsbmsSystEnums.Data.SystEnumItems/0` record.

  ## Examples

      iex> new_owner_state =
      ...>   MsbmsSystEnums.get_default_enum_item("owner_states")
      iex> {
      ...>   :ok,
      ...>   %MsbmsSystInstanceMgr.Data.SystOwners{
      ...>     internal_name: "owner_example_1"
      ...>     }
      ...> } =
      ...>   MsbmsSystInstanceMgr.create_owner(
      ...>     "owner_example_1",
      ...>     "Owner Example Creation",
      ...>     new_owner_state.id
      ...>   )
  """
  @spec create_owner(Types.owner_name(), String.t(), Ecto.UUID.t()) ::
          {:ok, Data.SystOwners.t()} | {:error, MsbmsSystError.t()}
  defdelegate create_owner(owner_name, owner_display_name, owner_state_id),
    to: Impl.Owners

  @doc """
  Retrieves a full `MsbmsSystInstanceMgr.Data.SystOwners` record by its
  internal_name.

  ## Parameters
    * `owner_name` - The internal name of the owner to retrieve.

  ## Examples

      iex> {
      ...>   :ok,
      ...>   %MsbmsSystInstanceMgr.Data.SystOwners{
      ...>     internal_name: "owner_1"
      ...>     }
      ...> } =
      ...>   MsbmsSystInstanceMgr.get_owner_by_name("owner_1")
  """
  @spec get_owner_by_name(Types.owner_name()) ::
          {:ok, Data.SystOwners.t()} | {:error, MsbmsSystError.t()}
  defdelegate get_owner_by_name(owner_name), to: Impl.Owners

  @doc """
  Updates an existing `MsbmsSystInstanceMgr.Data.SystOwners` record.

  ## Parameters

    * `owner_id` - he id of an existing SystOwners record.

    * `owner_params` - a map where the keys are a subset of the fields
      defined by `t:MsbmsSystInstanceMgr.Data.SystOwners/0`.  Only those keys
      representing values that are actually changing need be included in the map.
      The fields available for updating using this function are:

      * `internal_name` - a unique identifier for use in programmatic contexts.
        While this value may be changed after SystOwners creation, typically it
        will remain the same for the life of the record.  It is recommended to
        only allow changes when circumstances warrant a significant change to
        record identification.

      * `display_name` - a unique identifier used in UI and reporting end user
        displays.  This value is expected to be changed when convenient.

      * `owner_state_id` - The id of an existing
        `t:MsbmsSystEnums.Data.SystEnumItems/0` record which represents the new
        state of the SystOwners record.

  ## Examples

      MsbmsSystInstanceMgr.set_owner_values(
        owner.id,
        %{
          internal_name: "new_owner_name",
          display_name: "New Owner Display Name",
          owner_state_id: new_owner_state.id

        })
  """
  @spec set_owner_values(Ecto.UUID.t(), Types.owner_params()) ::
          {:ok, Data.SystOwners.t()} | {:error, MsbmsSystError.t()}
  defdelegate set_owner_values(owner_id, owner_params), to: Impl.Owners

  @doc """
  Deletes a single `MsbmsSystInstanceMgr.Data.SystOwners` record from the system.

  > #### Note {: .neutral}
  >
  > You can only purge SystOwners records when their Owner State is one that is
  > in the `owner_states` functional type `owner_states_purge_eligible`.  If the
  > SystOwners is in a state with a different functional type, an error tuple
  > will be returned.

  ## Parameters

    * `owner_id` - The id of the SystOwners record to purge.  The identified
      SystOwners record must exist or an error tuple will be returned.

  ## Examples

      iex> new_owner_state =
      ...>   MsbmsSystEnums.get_default_enum_item(
      ...>     "owner_states",
      ...>     functional_type_name: "owner_states_purge_eligible"
      ...>   )
      iex> { :ok, new_owner} =
      ...>   MsbmsSystInstanceMgr.create_owner(
      ...>     "example_purge",
      ...>     "Purge Example",
      ...>     new_owner_state.id
      ...>   )
      iex> {:ok, {1, _recs}} = MsbmsSystInstanceMgr.purge_owner(new_owner.id)

      iex> new_owner_state =
      ...>   MsbmsSystEnums.get_default_enum_item(
      ...>     "owner_states",
      ...>     functional_type_name: "owner_states_active"
      ...>   )
      iex> { :ok, new_owner} =
      ...>   MsbmsSystInstanceMgr.create_owner(
      ...>     "purge_failure_example",
      ...>     "Purge Failure Example",
      ...>     new_owner_state.id
      ...>   )
      iex> {:error, _reason} = MsbmsSystInstanceMgr.purge_owner(new_owner.id)
  """
  @spec purge_owner(Ecto.UUID.t()) ::
          {:ok, {non_neg_integer(), nil | [term()]}} | {:error, MsbmsSystError.t()}
  defdelegate purge_owner(owner_id), to: Impl.Owners

  @doc """
  Deletes all `MsbmsSystInstanceMgr.Data.SystOwners` records that are in a purge
  eligible owner state.

  Unlike the `MsbmsInstanceMgr.purge_owner/1`, this function will not return an
  `:error` tuple if there are no eligible records to purge.  In that case the
  deleted records count returned in the `:ok` tuple will simply be 0.
  """
  @spec purge_all_eligible_owners() ::
          {:ok, {non_neg_integer(), nil | [term()]}} | {:error, MsbmsSystError.t()}
  defdelegate purge_all_eligible_owners(), to: Impl.Owners

  @doc """
  Retrieves a list of `MsbmsSystInstanceMgr.Data.SystInstances` records set up
  in the system.

  The returned list is not the full data of the records, but a map of the most
  essential data defined by
  `t:MsbmsSystInstanceMgr.Types.instances_list_item/0`.
  """
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
  defdelegate list_instances(opts_given \\ []), to: Impl.Instances

  @spec get_instance_by_name(Types.instance_name()) ::
          {:ok, Data.SystInstances.t()} | {:error, MsbmsSystError.t()}
  defdelegate get_instance_by_name(instance_internal_name), to: Impl.Instances

  @spec list_instance_types() ::
          {:ok, list(MsbmsSystEnums.Data.SystEnumItems.t())} | {:error, MsbmsSystError.t()}
  defdelegate list_instance_types, to: Impl.InstanceTypes

  @spec create_instance_type(Types.instance_type()) ::
          {:ok, MsbmsSystEnums.Data.SystEnumItems.t()} | {:error, MsbmsSystError.t()}
  defdelegate create_instance_type(instance_type_params), to: Impl.InstanceTypes

  @spec get_instance_type_by_name(MsbmsSystEnums.Types.enum_item_name()) ::
          {:ok, MsbmsSystEnums.Data.SystEnumItems.t()} | {:error, MsbmsSystError.t()}
  defdelegate get_instance_type_by_name(instance_type_name), to: Impl.InstanceTypes

  @spec set_instance_type_values(
          MsbmsSystEnums.Types.enum_item_name(),
          Types.instance_type()
        ) :: {:ok, MsbmsSystEnums.Data.SystEnumItems.t()} | {:error, MsbmsSystError.t()}
  defdelegate set_instance_type_values(instance_type_name, instance_type_params),
    to: Impl.InstanceTypes
end
