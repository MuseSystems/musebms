defmodule IntegrationTest do
  @moduledoc false

  use ProcessTestCase, async: true

  @moduletag :integration
  @moduletag :capture_log

  alias Msutils.Process

  describe "whereis/1" do
    test "returns pid for locally registered process", %{local: %{pid: pid, name: name}} do
      assert {:ok, ^pid} = Process.whereis(name)
    end

    test "returns pid for globally registered process", %{global: %{pid: pid, name: name}} do
      assert {:ok, ^pid} = Process.whereis(name)
    end

    test "returns pid when given a pid directly", %{unnamed: %{pid: pid}} do
      assert {:ok, ^pid} = Process.whereis(pid)
    end

    test "returns error for non-existent local process" do
      assert {:error, %Mserror.ProcessUtilsError{kind: :lookup, cause: :process_not_found}} =
               Process.whereis(:nonexistent_process)
    end

    test "returns error for non-existent global process" do
      assert {:error, %Mserror.ProcessUtilsError{kind: :lookup, cause: :process_not_found}} =
               Process.whereis({:global, :nonexistent_process})
    end

    test "returns error for invalid process name" do
      assert {:error, %Mserror.ProcessUtilsError{kind: :lookup, cause: :invalid_name}} =
               Process.whereis({:invalid, :name})
    end

    test "returns pid for via-registered process", %{via: %{pid: pid, name: name}} do
      assert {:ok, ^pid} = Process.whereis(name)
    end

    test "returns error for non-existent via process" do
      assert {:error, %Mserror.ProcessUtilsError{kind: :lookup, cause: :process_not_found}} =
               Process.whereis(
                 {:via, Registry, {MscmpSystUtilsProcess.TestRegistry, :nonexistent_process}}
               )
    end
  end
end
