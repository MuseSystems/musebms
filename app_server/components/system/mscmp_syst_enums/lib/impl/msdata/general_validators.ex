# Source File: general_validators.ex
# Location:    musebms/app_server/components/system/mscmp_syst_enums/lib/impl/msdata/general_validators.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystEnums.Impl.Msdata.GeneralValidators do
  @moduledoc false

  import Ecto.Changeset

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
