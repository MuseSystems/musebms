# Source File: mix_builddb_task_test.exs
# Location:    musebms/components/system/msbms_syst_datastore/test/mix_builddb_task_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MixBuilddbTaskTest do
  use ExUnit.Case

  require IEx

  alias Mix.Tasks.Builddb

  @standard_migrations_root_dir "priv/database"

  @alternate_source_root_dir "database/alt_database"
  @alternate_migrations_root_dir "priv/alt_database"

  setup_all do
    on_exit(fn ->
      File.rm_rf!(@standard_migrations_root_dir)
      File.rm_rf!(@alternate_migrations_root_dir)
    end)

    :ok
  end

  @tag ds_type: :one
  test "Perform a simple build with no optional args" do
    assert :ok = Builddb.run(["-t", "test_type_one", "-c"])

    file_list =
      [@standard_migrations_root_dir, "test_type_one"]
      |> Path.join()
      |> File.ls!()
      |> Enum.sort()

    assert 11 = length(file_list)

    assert ["test_type_one.01.01.000.0000MS.000.eex.sql" | _] = file_list

    assert "test_type_one.03.01.44M.0000MS.000.eex.sql" = List.last(file_list)

    Enum.each(file_list, fn file_name ->
      file_content =
        [@standard_migrations_root_dir, "test_type_one", file_name]
        |> Path.join()
        |> File.read!()

      assert true =
               String.match?(
                 file_content,
                 ~r/#{file_name}/
               )
    end)
  end

  @tag ds_type: :two
  test "Perform a build with existing migrations" do
    assert :ok = Builddb.run(["-t", "test_type_two", "-c"])

    Path.wildcard(
      @standard_migrations_root_dir <>
        "/test_type_two/test_type_two.{02,03}.??.???.0000MS.???.eex.sql"
    )
    |> Enum.each(&File.rm!(&1))

    [@standard_migrations_root_dir, "test_type_two", "should_not_be_cleaned.txt"]
    |> Path.join()
    |> File.touch!()

    assert 4 =
             [@standard_migrations_root_dir, "test_type_two"]
             |> Path.join()
             |> File.ls!()
             |> length()

    assert :ok = Builddb.run(["-t", "test_type_two"])

    assert 12 =
             [@standard_migrations_root_dir, "test_type_two"]
             |> Path.join()
             |> File.ls!()
             |> length()

    [@standard_migrations_root_dir, "test_type_two", "should_not_be_cleaned.txt"]
    |> Path.join()
    |> File.rm!()

    file_list =
      Path.join([@standard_migrations_root_dir, "test_type_two"])
      |> File.ls!()
      |> Enum.sort()

    assert ["test_type_two.01.01.000.0000MS.000.eex.sql" | _] = file_list

    assert "test_type_two.03.01.44M.0000MS.000.eex.sql" = List.last(file_list)

    Enum.each(file_list, fn file_name ->
      file_content =
        ["priv/database/test_type_two", file_name]
        |> Path.join()
        |> File.read!()

      assert true = String.match?(file_content, ~r/#{file_name}/)
    end)
  end

  @tag ds_type: :three
  test "Perform a build with alternate source and migration directories" do
    assert :ok =
             Builddb.run([
               "-t",
               "test_type_three",
               "-c",
               "-s",
               @alternate_source_root_dir,
               "-d",
               @alternate_migrations_root_dir
             ])

    Path.wildcard(
      @alternate_migrations_root_dir <>
        "/test_type_three/test_type_three.{02,03}.??.???.0000MS.???.eex.sql"
    )
    |> Enum.each(&File.rm!(&1))

    [@alternate_migrations_root_dir, "test_type_three", "should_not_be_cleaned.txt"]
    |> Path.join()
    |> File.touch!()

    assert 4 =
             [@alternate_migrations_root_dir, "test_type_three"]
             |> Path.join()
             |> File.ls!()
             |> length()

    assert :ok =
             Builddb.run([
               "-t",
               "test_type_three",
               "-s",
               @alternate_source_root_dir,
               "-d",
               @alternate_migrations_root_dir
             ])

    assert 12 =
             [@alternate_migrations_root_dir, "test_type_three"]
             |> Path.join()
             |> File.ls!()
             |> length()

    [@alternate_migrations_root_dir, "test_type_three", "should_not_be_cleaned.txt"]
    |> Path.join()
    |> File.rm!()

    file_list =
      [@alternate_migrations_root_dir, "test_type_three"]
      |> Path.join()
      |> File.ls!()
      |> Enum.sort()

    assert ["test_type_three.01.01.000.0000MS.000.eex.sql" | _] = file_list

    assert "test_type_three.03.01.44M.0000MS.000.eex.sql" = List.last(file_list)

    Enum.each(file_list, fn file_name ->
      file_content =
        [@alternate_migrations_root_dir, "test_type_three", file_name]
        |> Path.join()
        |> File.read!()

      assert true = String.match?(file_content, ~r/#{file_name}/)
    end)
  end

  @tag ds_type: :five
  test "Perform a build when nested build plans are in use" do
    # TODO: Make this test more robust.  Really there are some content and
    #       ordering checks that should be made, but are more difficult and
    #       sensitive to implement.  Those failure scenarios are unlikely to 
    #       crop up in reality and so we'll just go with the "did it finish"
    #       level of testing below, but the internal checks should be added
    #       at some point.

    assert :ok = Builddb.run(["-t", "test_type_five", "-c"])

    file_list =
      [@standard_migrations_root_dir, "test_type_five"]
      |> Path.join()
      |> File.ls!()
      |> Enum.sort()

    assert 3 = length(file_list)

    assert ["test_type_five.01.01.000.0000MS.000.eex.sql" | _] = file_list

    assert "test_type_five.01.03.000.0000MS.000.eex.sql" = List.last(file_list)

    Enum.each(file_list, fn file_name ->
      file_content =
        [@standard_migrations_root_dir, "test_type_five", file_name]
        |> Path.join()
        |> File.read!()

      assert true =
               String.match?(
                 file_content,
                 ~r/#{file_name}/
               )
    end)
  end
end
