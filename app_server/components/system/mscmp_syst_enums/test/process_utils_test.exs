# Source File: process_utils_test.exs
# Location:    musebms/app_server/components/system/mscmp_syst_enums/test/process_utils_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule ProcessUtilsTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias MscmpSystEnums.Runtime.ProcessUtils

  @moduletag :unit
  @moduletag :capture_log

  defp reset_process_dict do
    Process.put(:"MscmpSystEnums.service_name", nil)
    Process.put(:"MscmpSystEnums.runtime_config", nil)
  end

  defp get_curr_service_name, do: Process.get(:"MscmpSystEnums.service_name")
  defp get_curr_runtime_config, do: Process.get(:"MscmpSystEnums.runtime_config")

  describe "put_service/1 tests" do
    test "putting a service name" do
      reset_process_dict()
      service_name = TestSupport.get_enums_service_name()

      assert nil === ProcessUtils.put_service(service_name)
      assert service_name === get_curr_service_name()
    end

    test "put_service/1 return values" do
      reset_process_dict()
      service_name = TestSupport.get_enums_service_name()

      assert nil === ProcessUtils.put_service(service_name)
      assert service_name === ProcessUtils.put_service(nil)
      assert nil === get_curr_service_name()
    end

    test "puttting an invalid service name" do
      reset_process_dict()
      service_name = TestSupport.get_enums_service_name()
      nil = ProcessUtils.put_service(service_name)

      current_service = ProcessUtils.get_service()
      current_config = ProcessUtils.get_runtime_config()

      catch_exit(ProcessUtils.put_service(:non_existent_enums_service))

      assert ProcessUtils.get_service() == current_service
      assert ProcessUtils.get_runtime_config() == current_config
    end

    test "Repeated calls don't change state" do
      reset_process_dict()
      service_name = TestSupport.get_enums_service_name()
      nil = ProcessUtils.put_service(service_name)

      runtime_config = get_curr_runtime_config()

      assert service_name === ProcessUtils.put_service(service_name)
      assert service_name === ProcessUtils.put_service(service_name)

      assert TestSupport.get_enums_service_name() ===
               Process.get(:"MscmpSystEnums.service_name")

      assert runtime_config === get_curr_runtime_config()
    end
  end

  describe "get_service/0 tests" do
    test "getting service name with service set" do
      reset_process_dict()
      service_name = TestSupport.get_enums_service_name()
      nil = ProcessUtils.put_service(service_name)

      assert service_name === ProcessUtils.get_service()
    end

    test "getting service name with no service set" do
      reset_process_dict()

      assert nil === ProcessUtils.get_service()
    end

    test "getting service name after service unset" do
      reset_process_dict()
      service_name = TestSupport.get_enums_service_name()
      nil = ProcessUtils.put_service(service_name)
      ^service_name = ProcessUtils.put_service(nil)

      assert nil === ProcessUtils.get_service()
    end

    test "getting service name with repeated sets and unset" do
      reset_process_dict()
      service_name = TestSupport.get_enums_service_name()

      assert nil === ProcessUtils.get_service()

      assert nil === ProcessUtils.put_service(service_name)
      assert service_name === ProcessUtils.get_service()
      assert service_name === ProcessUtils.put_service(service_name)
      assert service_name === ProcessUtils.get_service()
      assert service_name = ProcessUtils.put_service(nil)
      assert nil === ProcessUtils.put_service(service_name)
      assert service_name === ProcessUtils.get_service()

      assert service_name === ProcessUtils.put_service(nil)
      assert nil === ProcessUtils.get_service()
      assert nil === ProcessUtils.put_service(nil)
      assert nil === ProcessUtils.get_service()
      assert nil === ProcessUtils.put_service(service_name)
      assert service_name === ProcessUtils.put_service(nil)
      assert nil === ProcessUtils.get_service()
    end
  end

  describe "get_runtime_config/0 tests" do
    test "getting runtime config with service set" do
      reset_process_dict()
      service_name = TestSupport.get_enums_service_name()
      nil = ProcessUtils.put_service(service_name)

      runtime_config = ProcessUtils.get_runtime_config()

      assert %{datastore_context_name: datastore_context_name, enums_table: enums_table} =
               runtime_config

      assert is_reference(enums_table)

      assert {:via, Registry,
              {MscmpSystEnums.TestRegistry, TestSupport.get_datastore_context_name()}} ===
               datastore_context_name
    end

    test "getting runtime config with no service set" do
      reset_process_dict()

      assert nil === ProcessUtils.get_runtime_config()
    end

    test "getting runtime config after service unset" do
      reset_process_dict()
      service_name = TestSupport.get_enums_service_name()
      nil = ProcessUtils.put_service(service_name)

      assert %{datastore_context_name: _, enums_table: _} = ProcessUtils.get_runtime_config()

      ^service_name = ProcessUtils.put_service(nil)

      assert nil === ProcessUtils.get_runtime_config()
    end

    test "getting runtime config with repeated sets and unset" do
      reset_process_dict()
      service_name = TestSupport.get_enums_service_name()

      assert nil === ProcessUtils.get_runtime_config()

      assert nil === ProcessUtils.put_service(service_name)
      assert %{} = runtime_config = ProcessUtils.get_runtime_config()
      assert service_name === ProcessUtils.put_service(service_name)
      assert runtime_config === ProcessUtils.get_runtime_config()
      assert service_name === ProcessUtils.put_service(nil)
      assert nil === ProcessUtils.put_service(service_name)
      assert runtime_config === ProcessUtils.get_runtime_config()

      assert service_name === ProcessUtils.put_service(nil)
      assert nil === ProcessUtils.get_runtime_config()
      assert nil === ProcessUtils.put_service(nil)
      assert nil === ProcessUtils.get_runtime_config()
      assert nil === ProcessUtils.put_service(service_name)
      assert service_name === ProcessUtils.put_service(nil)
      assert nil === ProcessUtils.get_runtime_config()
    end
  end

  describe "error conditions and edge cases" do
    test "handles non-existent service gracefully" do
      current_service = ProcessUtils.get_service()
      current_config = ProcessUtils.get_runtime_config()

      catch_exit(ProcessUtils.put_service(:non_existent_limiter_service))

      assert ProcessUtils.get_service() == current_service
      assert ProcessUtils.get_runtime_config() == current_config
    end

    test "ensure shape of runtime time config" do
      reset_process_dict()
      service_name = TestSupport.get_enums_service_name()

      assert nil === ProcessUtils.get_runtime_config()

      _ = ProcessUtils.put_service(service_name)
      runtime_config = ProcessUtils.get_runtime_config()

      assert %{datastore_context_name: datastore_context_name, enums_table: enums_table} =
               runtime_config

      assert is_reference(enums_table)

      assert {:via, Registry,
              {MscmpSystEnums.TestRegistry, TestSupport.get_datastore_context_name()}} ===
               datastore_context_name
    end
  end
end
