defmodule Msutils.Data do
  @external_resource "README.md"
  @moduledoc Path.join([__DIR__, "..", "..", "README.md"])
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  alias MscmpSystError.Types.Context, as: ErrorContext
  alias MscmpSystUtilsData.Impl
  alias Msutils.Data.Types

  ##############################################################################
  #
  # ETS Operations
  #
  #

  @doc section: :ets_operations
  @doc """
  Inserts data into an ETS table.

  In this we wrap the ETS `:ets.insert/2` function in a function that returns
  an Mserror.DataUtilsError if there is an error.

  ## Parameters

    * `table` - the ETS table to insert the data into.

    * `data` - the data to insert into the ETS table.

  ## Returns

    * `:ok` - if the data was successfully inserted into the ETS table.

    * `{:error, Mserror.DataUtilsError.t()}` - if there was an error inserting
      the data into the ETS table.

  """
  @spec ets_insert(:ets.table(), term()) :: :ok | {:error, Mserror.DataUtilsError.t()}
  def ets_insert(table, data) do
    case Impl.Ets.ets_insert(table, data) do
      :ok ->
        :ok

      {:error, _} = error ->
        {:error,
         Mserror.DataUtilsError.new(:ets_operations, "Error inserting data into ETS table",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :ets_insert, 2},
             parameters: %{table: table, data: data}
           }
         )}
    end
  end

  @doc section: :ets_operations
  @doc """
  Looks up an element in an ETS table by key and position.

  Wraps the ETS `:ets.lookup_element/3` function, returning a result tuple.

  ## Parameters

    * `table` - the ETS table to look up the element in
    * `key` - the key to look up
    * `element_index` - the position of the element to return

  ## Returns

    * `{:ok, term()}` - the element was found at the specified position
    * `{:error, Mserror.DataUtilsError.t()}` - if there was an error during lookup
  """
  @spec ets_lookup_element(:ets.table(), term(), non_neg_integer()) ::
          {:ok, term()} | {:error, Mserror.DataUtilsError.t()}
  def ets_lookup_element(table, key, element_index) do
    case Impl.Ets.ets_lookup_element(table, key, element_index) do
      {:ok, value} ->
        {:ok, value}

      {:error, _} = error ->
        {:error,
         Mserror.DataUtilsError.new(:ets_operations, "Error looking up element in ETS table",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :ets_lookup_element, 3},
             parameters: %{table: table, key: key, element_index: element_index}
           }
         )}
    end
  end

  @doc section: :ets_operations
  @doc """
  Updates an element in an ETS table.

  Wraps the ETS `:ets.update_element/3` function.

  ## Parameters

    * `table` - the ETS table to update
    * `key` - the key of the element to update
    * `updated_data` - the new data to set

  ## Returns

    * `:ok` - if the update was successful
    * `{:error, Mserror.DataUtilsError.t()}` - if there was an error during update
  """
  @spec ets_update_element(:ets.table(), term(), term()) ::
          :ok | {:error, Mserror.DataUtilsError.t()}
  def ets_update_element(table, key, updated_data) do
    case Impl.Ets.ets_update_element(table, key, updated_data) do
      :ok ->
        :ok

      {:error, _} = error ->
        {:error,
         Mserror.DataUtilsError.new(:ets_operations, "Error updating element in ETS table",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :ets_update_element, 3},
             parameters: %{table: table, key: key, updated_data: updated_data}
           }
         )}
    end
  end

  @doc section: :ets_operations
  @doc """
  Deletes an entry from an ETS table.

  Wraps the ETS `:ets.delete/2` function.

  ## Parameters

    * `table` - the ETS table to delete from
    * `key` - the key of the entry to delete

  ## Returns

    * `:ok` - if the deletion was successful
    * `{:error, Mserror.DataUtilsError.t()}` - if there was an error during deletion
  """
  @spec ets_delete(:ets.table(), term()) :: :ok | {:error, Mserror.DataUtilsError.t()}
  def ets_delete(table, key) do
    case Impl.Ets.ets_delete(table, key) do
      :ok ->
        :ok

      {:error, _} = error ->
        {:error,
         Mserror.DataUtilsError.new(:ets_operations, "Error deleting entry from ETS table",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :ets_delete, 2},
             parameters: %{table: table, key: key}
           }
         )}
    end
  end

  ##############################################################################
  #
  # Common Validator Option Definitions
  #
  #

  @common_validator_option_defs [
    internal_name: [
      min_internal_name_length: [
        type: :pos_integer,
        default: 6,
        doc: "Sets the minimum grapheme length of internal_name values."
      ],
      max_internal_name_length: [
        type: :pos_integer,
        default: 64,
        doc: "Sets the maximum grapheme length of internal_name values."
      ]
    ],
    display_name: [
      min_display_name_length: [
        type: :pos_integer,
        default: 6,
        doc: "Sets the minimum grapheme length of display_name values."
      ],
      max_display_name_length: [
        type: :pos_integer,
        default: 64,
        doc: "Sets the maximum grapheme length of display_name values."
      ]
    ],
    external_name: [
      min_external_name_length: [
        type: :pos_integer,
        default: 2,
        doc: "Sets the minimum grapheme length of external_name values."
      ],
      max_external_name_length: [
        type: :pos_integer,
        default: 64,
        doc: "Sets the maximum grapheme length of external_name values."
      ]
    ],
    user_description: [
      min_user_description_length: [
        type: :pos_integer,
        default: 6,
        doc: "Sets the minimum grapheme length of user_description values."
      ],
      max_user_description_length: [
        type: :pos_integer,
        default: 1_000,
        doc: "Sets the maximum grapheme length of user_description values."
      ]
    ]
  ]

  ##############################################################################
  #
  # validate_internal_name
  #
  #

  @doc section: :changeset_validators
  @doc """
  Changeset validation ensuring that the `internal_name` field is valid and
  meets minimum and maximum length requirements.

  ## Parameters

    * `changeset` - an `Ecto.Changeset` struct to be validated.

    * `opts` - options which configure the validation checks of the functions.

  ## Options

    #{NimbleOptions.docs(NimbleOptions.new!(Keyword.get(@common_validator_option_defs, :internal_name)))}

  """
  @spec validate_internal_name(Ecto.Changeset.t(), Keyword.t()) :: Ecto.Changeset.t()
  defdelegate validate_internal_name(changeset, opts), to: Impl.Validators

  ##############################################################################
  #
  # validate_display_name
  #
  #

  @doc section: :changeset_validators
  @doc """
  Changeset validation ensuring that the `display_name` field is valid and
  meets minimum and maximum length requirements.

  ## Parameters

    * `changeset` - an `Ecto.Changeset` struct to be validated.

    * `opts` - options which configure the validation checks of the functions.

  ## Options

    #{NimbleOptions.docs(NimbleOptions.new!(Keyword.get(@common_validator_option_defs, :display_name)))}

  """
  @spec validate_display_name(Ecto.Changeset.t(), Keyword.t()) :: Ecto.Changeset.t()
  defdelegate validate_display_name(changeset, opts), to: Impl.Validators

  ##############################################################################
  #
  # validate_external_name
  #
  #

  @doc section: :changeset_validators
  @doc """
  Changeset validation ensuring that the `external_name` field is valid and
  meets minimum and maximum length requirements.

  ## Parameters

    * `changeset` - an `Ecto.Changeset` struct to be validated.

    * `opts` - options which configure the validation checks of the functions.

  ## Options

    #{NimbleOptions.docs(NimbleOptions.new!(Keyword.get(@common_validator_option_defs, :external_name)))}
  """
  @spec validate_external_name(Ecto.Changeset.t(), Keyword.t()) :: Ecto.Changeset.t()
  defdelegate validate_external_name(changeset, opts), to: Impl.Validators

  ##############################################################################
  #
  # validate_user_description
  #
  #

  @doc section: :changeset_validators
  @doc """
  Changeset validation ensuring that the `user_description` field is set if
  required and allowed and meets minimum and maximum length requirements.

  ## Parameters

    * `changeset` - an `Ecto.Changeset` struct to be validated.

    * `opts` - options which configure the validation checks of the functions.

  ## Options

    #{NimbleOptions.docs(NimbleOptions.new!(Keyword.get(@common_validator_option_defs, :user_description)))}
  """
  @spec validate_user_description(Ecto.Changeset.t(), Keyword.t()) :: Ecto.Changeset.t()
  defdelegate validate_user_description(changeset, opts), to: Impl.Validators

  ##############################################################################
  #
  # validate_syst_defined_changes
  #
  #
  @doc section: :changeset_validators
  @doc """
  Changeset validation ensuring that, if the record is set as `syst_defined`,
  the prohibited fields are not changed.

  ## Parameters

    * `changeset` - an `Ecto.Changeset` struct to be validated.

    * `prohibited_fields` - a list of field names for which changes are
      prohibited if the record is set as `syst_defined`.
  """
  @spec validate_syst_defined_changes(Ecto.Changeset.t(), list(atom())) :: Ecto.Changeset.t()
  defdelegate validate_syst_defined_changes(changeset, prohibited_fields), to: Impl.Validators

  ##############################################################################
  #
  # common_validator_options
  #
  #

  @doc """
  Returns a NimbleOptions struct with the requested common validator options for
  use with the Changeset validation functions from the Msutils.Data module.

  The common validator options establish cross-Component standards for data
  limits such as minimum and maximum lengths commonly used data fields.  In many
  ways, these options act as constants for common Changeset validations.

  ## Parameters

    * `selected_options` - selects the desired options from the common validator
      option definitions.  This is in the form of a list of the desired options.

  ## Select Options

    The following are accepted for selected options:

  #{Enum.map_join(@common_validator_option_defs, "\n\n", fn {key, _} -> "  * `:#{key}`" end)}

  """
  @spec common_validator_options(selected_options :: [Types.common_validators()]) ::
          Macro.t()
  defmacro common_validator_options(selected_options) do
    resolved_options =
      case selected_options do
        selected_options when is_list(selected_options) ->
          valid_options = Keyword.keys(@common_validator_option_defs)
          invalid_selections = selected_options -- valid_options

          if invalid_selections != [] do
            raise Mserror.DataUtilsError,
              kind: :macro,
              message: "Invalid changeset validator options were requested",
              context: %ErrorContext{
                origin: {__MODULE__, :common_validator_options, 1},
                parameters: %{selected_options: selected_options}
              }
          end

          @common_validator_option_defs
          |> Keyword.take(selected_options)
          |> Keyword.values()
          |> List.flatten()
          |> NimbleOptions.new!()

        _ ->
          raise Mserror.DataUtilsError,
            kind: :macro,
            message: """
              Invalid options selector provided.  Your selections should be a
              list of the validators you require.
            """,
            context: %ErrorContext{
              origin: {__MODULE__, :common_validator_options, 1},
              parameters: %{selected_options: selected_options}
            }
      end

    quote do
      unquote(Macro.escape(resolved_options))
    end
  end
end
