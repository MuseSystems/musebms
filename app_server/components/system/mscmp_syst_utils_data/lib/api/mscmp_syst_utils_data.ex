defmodule Msutils.Data do
  @external_resource "README.md"
  @moduledoc Path.join([__DIR__, "..", "..", "README.md"])
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  alias MscmpSystUtilsData.Impl
  alias Msutils.Data.Types

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
        default: 6,
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
              kind: :macro_error,
              message: "Invalid changeset validator options were requested",
              context: %MscmpSystError.Types.Context{
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
            kind: :macro_error,
            message: """
              Invalid options selector provided.  Your selections should be a
              list of the validators you require.
            """,
            context: %MscmpSystError.Types.Context{
              origin: {__MODULE__, :common_validator_options, 1},
              parameters: %{selected_options: selected_options}
            }
      end

    quote do
      unquote(Macro.escape(resolved_options))
    end
  end
end
