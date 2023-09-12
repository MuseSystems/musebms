# Source File: general.ex
# Location:    musebms/components/system/mscmp_syst_perms/lib/msdata/validators/general.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystPerms.Msdata.Validators.General do
  @moduledoc false

  import Ecto.Changeset

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
    changeset
    |> validate_required(:internal_name)
    |> validate_length(:internal_name,
      min: opts[:min_internal_name_length],
      max: opts[:max_internal_name_length]
    )
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
  end

  # Validate the external_name key for the changeset.
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

  # Validates that if the record is designated as system defined, only allowed
  # fields are being updated.
  @spec validate_syst_defined_changes(Ecto.Changeset.t(), list(atom())) :: Ecto.Changeset.t()
  def validate_syst_defined_changes(changeset, prohibited_fields) do
    changeset
    |> resolve_syst_defined()
    |> maybe_test_prohibited_fields(prohibited_fields)
  end

  defp resolve_syst_defined(changeset) do
    system_defined = get_field(changeset, :syst_defined, false)
    {system_defined, changeset}
  end

  defp maybe_test_prohibited_fields({false, changeset}, _prohibited_fields), do: changeset

  defp maybe_test_prohibited_fields({true, changeset}, prohibited_fields) do
    reducer_func = fn curr_field, changeset ->
      case fetch_change(changeset, curr_field) do
        {:ok, _value} ->
          add_error(
            changeset,
            curr_field,
            "You may not change this field when the record is system defined."
          )

        :error ->
          changeset
      end
    end

    Enum.reduce(prohibited_fields, changeset, reducer_func)
  end
end
