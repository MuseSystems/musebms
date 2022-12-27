# Source File: changeset_helpers.ex
# Location:    musebms/components/system/mscmp_syst_enums/lib/impl/changeset_helpers.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystEnums.Impl.ChangesetHelpers do
  import Ecto.Changeset

  @moduledoc false

  @default_min_internal_name_length 6
  @default_max_internal_name_length 64

  @default_min_display_name_length 6
  @default_max_display_name_length 64

  @default_min_external_name_length 6
  @default_max_external_name_length 64

  @default_min_user_description_length 6
  @default_max_user_description_length 1_000

  # Resolve user provided options to a complete set of options by filling gaps
  # with pre-defined defaults.
  #
  # Allows the changeset function to resolve defaults that are used to
  # parameterize other validations.   We do that resolution in the changeset
  # function directly so we're only doing the user/default resolution once for
  # a changeset.
  @spec resolve_options(Keyword.t()) :: Keyword.t()
  def resolve_options(opts_given) do
    MscmpSystUtils.resolve_options(opts_given,
      min_internal_name_length: @default_min_internal_name_length,
      max_internal_name_length: @default_max_internal_name_length,
      min_display_name_length: @default_min_display_name_length,
      max_display_name_length: @default_max_display_name_length,
      min_external_name_length: @default_min_external_name_length,
      max_external_name_length: @default_max_external_name_length,
      min_user_description_length: @default_min_user_description_length,
      max_user_description_length: @default_max_user_description_length
    )
  end

  # Validate the internal_name key for the changeset.
  #
  # Options:
  # min_internal_name_length - Sets the minimum grapheme length of internal_name
  #                            values.
  #
  # max_internal_name_length - Sets the maximum grapheme length of internal_name
  #                            values.
  @spec validate_internal_name(Ecto.Changeset.t(), Keyword.t()) :: Ecto.Changeset.t()
  def validate_internal_name(changeset, opts) do
    opts = resolve_options(opts)

    validation_func = fn :internal_name, _internal_name ->
      if get_field(changeset, :syst_defined, false) == true do
        [internal_name: "System defined enumerations may not have their internal names changed."]
      else
        []
      end
    end

    changeset
    |> validate_required(:internal_name)
    |> validate_change(:internal_name, :validate_internal_name, &validation_func.(&1, &2))
    |> validate_length(:internal_name,
      min: opts[:min_internal_name_length],
      max: opts[:max_internal_name_length]
    )
    |> unique_constraint(:internal_name)
  end

  # Validate the display_name key for the changeset.
  #
  # Options:
  # min_display_name_length - Sets the minimum grapheme length of display_name
  #                           values.
  #
  # max_display_name_length - Sets the maximum grapheme length of display_name
  #                           values.
  @spec validate_display_name(Ecto.Changeset.t(), Keyword.t()) :: Ecto.Changeset.t()
  def validate_display_name(changeset, opts) do
    changeset
    |> validate_required(:display_name)
    |> validate_length(:display_name,
      min: opts[:min_display_name_length],
      max: opts[:max_display_name_length]
    )
    |> unique_constraint(:display_name)
  end

  # Validate the external_name field for the changeset.
  #
  # Options:
  # min_external_name_length - Sets the minimum grapheme length of external_name
  #                           values.
  #
  # max_external_name_length - Sets the maximum grapheme length of external_name
  #                           values.
  @spec validate_external_name(Ecto.Changeset.t(), Keyword.t()) :: Ecto.Changeset.t()
  def validate_external_name(changeset, opts) do
    changeset
    |> validate_required(:external_name)
    |> validate_length(:external_name,
      min: opts[:min_external_name_length],
      max: opts[:max_external_name_length]
    )
  end

  # Validate the user_description field for the changeset
  #
  # System defined enumerations are allowed to have a nil user descriptions, but
  # all other user description values must meet min/max length requirements.
  #
  # Options:
  # min_user_description_length - Sets the minimum grapheme length of
  #                               user_description values.
  #
  # max_user_description_length - Sets the maximum grapheme length of
  #                               user_description values.
  @spec validate_user_description(Ecto.Changeset.t(), Keyword.t()) :: Ecto.Changeset.t()
  def validate_user_description(changeset, opts) do
    (!get_field(changeset, :syst_defined) or !is_nil(get_field(changeset, :user_description, nil)))
    |> validate_user_description(changeset, opts)
  end

  defp validate_user_description(true, changeset, opts) do
    changeset
    |> validate_required(:user_description)
    |> validate_length(:user_description,
      min: opts[:min_user_description_length],
      max: opts[:max_user_description_length]
    )
  end

  defp validate_user_description(false, changeset, _opts), do: changeset

  # Validate enum_id field
  #
  # On inserts, the enum_id field is required, but on updates we cannot switch
  # parent enums.  When the id field is null, we assume we're inserting.
  @spec validate_enum_id(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def validate_enum_id(changeset) do
    validation_func = fn :enum_id, _enum_id ->
      if is_binary(get_field(changeset, :id, nil)) and
           is_binary(get_change(changeset, :enum_id, nil)) do
        [enum_id: "You cannot change the parent enumeration of an existing record."]
      else
        []
      end
    end

    changeset
    |> validate_required(:enum_id)
    |> validate_change(:enum_id, :validate_enum_id, &validation_func.(&1, &2))
  end

  # Validate functional_type_id field
  #
  # On inserts, the functional type id is required if the parent enumeration has
  # functional types defined.  One updates, the functional type, if any exist,
  # cannot be changed because changing functional type implies differences in
  # application behavior: business records that may be mid-process might have
  # their state inadvertently altered by such a functional type change.
  #
  # Currently we let the database deal with the question of a functional type
  # being required or not since we'd have extra work to deal with that question
  # in the application code.
  @spec validate_functional_type_id(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def validate_functional_type_id(changeset) do
    validation_func = fn :functional_type_id, _functional_type_id ->
      if is_binary(get_field(changeset, :id, nil)) and
           is_binary(get_change(changeset, :functional_type_id, nil)) do
        [
          functional_type_id:
            "You cannot change the parent functional type of an existing record."
        ]
      else
        []
      end
    end

    changeset
    # |> validate_required(:functional_type_id)
    |> validate_change(
      :functional_type_id,
      :validate_functional_type_id,
      &validation_func.(&1, &2)
    )
  end

  # Add a change for syst_defined set to false if creating a new record.
  #
  # Applications that create system defined enumerations should not use this
  # module to create them, but should instead create them directly via database
  # migrations.  This function will ensure that the syst_defined value is
  # set to false for new records.
  #
  # A record is considered to be new if the :id field is nil.
  @spec maybe_put_syst_defined(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def maybe_put_syst_defined(changeset) do
    changeset
    |> get_field(:id, nil)
    |> is_nil()
    |> maybe_put_syst_defined(changeset)
  end

  defp maybe_put_syst_defined(true, changeset), do: put_change(changeset, :syst_defined, false)
  defp maybe_put_syst_defined(false, changeset), do: changeset

  # Add a change for user_maintainable set to true if creating a new record.
  #
  # All new records created by the application using this method are considered
  # to be user defined and therefore necessarily user maintainable.  This
  # function ensures that, for any new record, the user_maintainable field is
  # set to true.
  #
  # A record is considered to be new if the :id field is nil.
  @spec maybe_put_user_maintainable(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def maybe_put_user_maintainable(changeset) do
    changeset
    |> get_field(:id, nil)
    |> is_nil()
    |> maybe_put_user_maintainable(changeset)
  end

  defp maybe_put_user_maintainable(true, changeset),
    do: put_change(changeset, :user_maintainable, true)

  defp maybe_put_user_maintainable(false, changeset), do: changeset
end
