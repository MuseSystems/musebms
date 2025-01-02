defmodule ProcessTest do
  @moduledoc false

  use ProcessTestCase, async: true

  @moduletag :unit
  @moduletag :capture_log

  alias MscmpSystUtilsProcess.Impl.Process

  describe "get_pid/1" do
    test "returns pid for locally registered process", %{local: %{pid: pid, name: name}} do
      assert {:ok, ^pid} = Process.get_pid(name)
    end

    test "returns pid for globally registered process", %{global: %{pid: pid, name: name}} do
      assert {:ok, ^pid} = Process.get_pid(name)
    end

    test "returns pid when given a pid directly", %{unnamed: %{pid: pid}} do
      assert {:ok, ^pid} = Process.get_pid(pid)
    end

    test "returns error for non-existent local process" do
      assert {:error, {:process_not_found, _}} = Process.get_pid(:nonexistent_process)
    end

    test "returns error for non-existent global process" do
      assert {:error, {:process_not_found, _}} = Process.get_pid({:global, :nonexistent_process})
    end

    test "returns error for invalid process name" do
      assert {:error, {:invalid_name, _}} = Process.get_pid({:invalid, :name})
    end

    test "returns pid for via-registered process", %{via: %{pid: pid, name: name}} do
      assert {:ok, ^pid} = Process.get_pid(name)
    end

    test "returns error for non-existent via process" do
      assert {:error, {:process_not_found, _}} =
               Process.get_pid(
                 {:via, Registry, {MscmpSystUtilsProcess.TestRegistry, :nonexistent_process}}
               )
    end
  end
end
