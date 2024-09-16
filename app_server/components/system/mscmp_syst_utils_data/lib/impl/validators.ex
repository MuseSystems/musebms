# Source File: validators.ex
# Location:    musebms/app_server/components/system/mscmp_syst_utils_data/lib/impl/validators.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystUtilsData.Impl.Validators do
  @moduledoc false

  import Ecto.Changeset

  ##############################################################################
  #
  # validate_internal_name
  #
  #

  @spec validate_internal_name(Ecto.Changeset.t(), Keyword.t()) :: Ecto.Changeset.t()
  def validate_internal_name(changeset, opts) do
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
  end

  ##############################################################################
  #
  # validate_display_name
  #
  #

  @spec validate_display_name(Ecto.Changeset.t(), Keyword.t()) :: Ecto.Changeset.t()
  def validate_display_name(changeset, opts) do
    changeset
    |> validate_required(:display_name)
    |> validate_length(:display_name,
      min: opts[:min_display_name_length],
      max: opts[:max_display_name_length]
    )
  end

  ##############################################################################
  #
  # validate_external_name
  #
  #

  @spec validate_external_name(Ecto.Changeset.t(), Keyword.t()) :: Ecto.Changeset.t()
  def validate_external_name(changeset, opts) do
    changeset
    |> validate_required(:external_name)
    |> validate_length(:external_name,
      min: opts[:min_external_name_length],
      max: opts[:max_external_name_length]
    )
  end

  ##############################################################################
  #
  # validate_user_description
  #
  #

  @spec validate_user_description(Ecto.Changeset.t(), Keyword.t()) :: Ecto.Changeset.t()
  def validate_user_description(changeset, opts) do
    (!get_field(changeset, :syst_defined, false) or
       !is_nil(get_field(changeset, :user_description, nil)))
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

  ##############################################################################
  #
  # validate_syst_defined_changes
  #
  #

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
