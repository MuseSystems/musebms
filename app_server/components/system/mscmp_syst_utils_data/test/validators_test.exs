# Source File: validators_test.exs
# Location:    musebms/app_server/components/system/mscmp_syst_utils_data/test/validators_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule ValidatorsTest do
  @moduledoc false

  use ExUnit.Case

  alias Ecto.Changeset
  alias MscmpSystUtilsData.Impl.Validators

  @moduletag :unit
  @moduletag :capture_log

  describe "validate_internal_name/2" do
    test "validates required internal_name" do
      changeset = Changeset.cast({%{}, %{internal_name: :string}}, %{}, [:internal_name])

      result =
        Validators.validate_internal_name(changeset,
          min_internal_name_length: 1,
          max_internal_name_length: 50
        )

      assert "can't be blank" in errors_on(result).internal_name
    end

    test "validates internal_name length" do
      changeset =
        Changeset.cast({%{}, %{internal_name: :string}}, %{internal_name: "a"}, [:internal_name])

      result =
        Validators.validate_internal_name(changeset,
          min_internal_name_length: 2,
          max_internal_name_length: 50
        )

      assert "should be at least 2 character(s)" in errors_on(result).internal_name

      changeset =
        Changeset.cast(
          {%{}, %{internal_name: :string}},
          %{internal_name: String.duplicate("a", 51)},
          [:internal_name]
        )

      result =
        Validators.validate_internal_name(changeset,
          min_internal_name_length: 1,
          max_internal_name_length: 50
        )

      assert "should be at most 50 character(s)" in errors_on(result).internal_name
    end

    test "prevents changing internal_name for system defined enumerations" do
      changeset =
        Changeset.cast(
          {%{syst_defined: true}, %{internal_name: :string, syst_defined: :boolean}},
          %{internal_name: "new_name"},
          [:internal_name, :syst_defined]
        )

      result =
        Validators.validate_internal_name(changeset,
          min_internal_name_length: 1,
          max_internal_name_length: 50
        )

      assert "System defined enumerations may not have their internal names changed." in errors_on(
               result
             ).internal_name
    end

    test "successfully validates valid internal_name" do
      changeset =
        Changeset.cast({%{}, %{internal_name: :string}}, %{internal_name: "valid_name"}, [
          :internal_name
        ])

      result =
        Validators.validate_internal_name(changeset,
          min_internal_name_length: 1,
          max_internal_name_length: 50
        )

      assert errors_on(result) == %{}
    end
  end

  describe "validate_display_name/2" do
    test "validates required display_name" do
      changeset = Changeset.cast({%{}, %{display_name: :string}}, %{}, [:display_name])

      result =
        Validators.validate_display_name(changeset,
          min_display_name_length: 1,
          max_display_name_length: 50
        )

      assert "can't be blank" in errors_on(result).display_name
    end

    test "validates display_name length" do
      changeset =
        Changeset.cast({%{}, %{display_name: :string}}, %{display_name: "a"}, [:display_name])

      result =
        Validators.validate_display_name(changeset,
          min_display_name_length: 2,
          max_display_name_length: 50
        )

      assert "should be at least 2 character(s)" in errors_on(result).display_name

      changeset =
        Changeset.cast(
          {%{}, %{display_name: :string}},
          %{display_name: String.duplicate("a", 51)},
          [:display_name]
        )

      result =
        Validators.validate_display_name(changeset,
          min_display_name_length: 1,
          max_display_name_length: 50
        )

      assert "should be at most 50 character(s)" in errors_on(result).display_name
    end

    test "successfully validates valid display_name" do
      changeset =
        Changeset.cast({%{}, %{display_name: :string}}, %{display_name: "Valid Display Name"}, [
          :display_name
        ])

      result =
        Validators.validate_display_name(changeset,
          min_display_name_length: 1,
          max_display_name_length: 50
        )

      assert errors_on(result) == %{}
    end
  end

  describe "validate_external_name/2" do
    test "validates required external_name" do
      changeset = Changeset.cast({%{}, %{external_name: :string}}, %{}, [:external_name])

      result =
        Validators.validate_external_name(changeset,
          min_external_name_length: 1,
          max_external_name_length: 50
        )

      assert "can't be blank" in errors_on(result).external_name
    end

    test "validates external_name length" do
      changeset =
        Changeset.cast({%{}, %{external_name: :string}}, %{external_name: "a"}, [:external_name])

      result =
        Validators.validate_external_name(changeset,
          min_external_name_length: 2,
          max_external_name_length: 50
        )

      assert "should be at least 2 character(s)" in errors_on(result).external_name

      changeset =
        Changeset.cast(
          {%{}, %{external_name: :string}},
          %{external_name: String.duplicate("a", 51)},
          [:external_name]
        )

      result =
        Validators.validate_external_name(changeset,
          min_external_name_length: 1,
          max_external_name_length: 50
        )

      assert "should be at most 50 character(s)" in errors_on(result).external_name
    end

    test "successfully validates valid external_name" do
      changeset =
        Changeset.cast(
          {%{}, %{external_name: :string}},
          %{external_name: "Valid External Name"},
          [:external_name]
        )

      result =
        Validators.validate_external_name(changeset,
          min_external_name_length: 1,
          max_external_name_length: 50
        )

      assert errors_on(result) == %{}
    end
  end

  describe "validate_user_description/2" do
    test "validates required user_description for non-system defined enumerations" do
      changeset =
        Changeset.cast(
          {%{syst_defined: false}, %{user_description: :string, syst_defined: :boolean}},
          %{},
          [:user_description, :syst_defined]
        )

      result =
        Validators.validate_user_description(changeset,
          min_user_description_length: 1,
          max_user_description_length: 500
        )

      assert "can't be blank" in errors_on(result).user_description
    end

    test "validates user_description length for non-system defined enumerations" do
      changeset =
        Changeset.cast(
          {%{syst_defined: false}, %{user_description: :string, syst_defined: :boolean}},
          %{user_description: "a"},
          [:user_description, :syst_defined]
        )

      result =
        Validators.validate_user_description(changeset,
          min_user_description_length: 2,
          max_user_description_length: 500
        )

      assert "should be at least 2 character(s)" in errors_on(result).user_description

      changeset =
        Changeset.cast(
          {%{syst_defined: false}, %{user_description: :string, syst_defined: :boolean}},
          %{user_description: String.duplicate("a", 501)},
          [:user_description, :syst_defined]
        )

      result =
        Validators.validate_user_description(changeset,
          min_user_description_length: 1,
          max_user_description_length: 500
        )

      assert "should be at most 500 character(s)" in errors_on(result).user_description
    end

    test "does not require user_description for system defined enumerations" do
      changeset =
        Changeset.cast(
          {%{syst_defined: true}, %{user_description: :string, syst_defined: :boolean}},
          %{},
          [:user_description, :syst_defined]
        )

      result =
        Validators.validate_user_description(changeset,
          min_user_description_length: 1,
          max_user_description_length: 500
        )

      assert errors_on(result) == %{}
    end

    test "successfully validates valid user_description for non-system defined enumerations" do
      changeset =
        Changeset.cast(
          {%{syst_defined: false}, %{user_description: :string, syst_defined: :boolean}},
          %{user_description: "This is a valid user description."},
          [:user_description, :syst_defined]
        )

      result =
        Validators.validate_user_description(changeset,
          min_user_description_length: 1,
          max_user_description_length: 500
        )

      assert errors_on(result) == %{}
    end
  end

  defp errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
