# Source File: network_rules_test.exs
# Location:    musebms/components/system/msbms_syst_authentication/test/network_rules_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule NetworkRulesTest do
  use AuthenticationTestCase, async: true

  import IP

  alias MsbmsSystAuthentication.Data
  alias MsbmsSystAuthentication.Impl

  test "Can determine if host is disallowed or not" do
    assert {:ok, true} = Impl.NetworkRules.host_disallowed(~i"10.123.123.3")
    assert {:ok, false} = Impl.NetworkRules.host_disallowed(~i"10.123.123.10")
  end

  test "Can create Disallowed Host" do
    {:ok, false} = Impl.NetworkRules.host_disallowed(~i"10.122.122.1")
    assert {:ok, _} = Impl.NetworkRules.create_disallowed_host(~i"10.122.122.1")
    assert {:ok, true} = Impl.NetworkRules.host_disallowed(~i"10.122.122.1")
  end

  test "Can delete Disallowed Host by record ID" do
    {:ok, true} = Impl.NetworkRules.host_disallowed(~i"10.10.250.1")

    {:ok, disallowed_host_record} =
      Impl.NetworkRules.get_disallowed_host_record_by_host(~i"10.10.250.1")

    assert {:ok, :deleted} = Impl.NetworkRules.delete_disallowed_host(disallowed_host_record.id)
    assert {:ok, false} = Impl.NetworkRules.host_disallowed(~i"10.10.250.1")

    assert {:ok, :not_found} = Impl.NetworkRules.delete_disallowed_host(disallowed_host_record.id)
  end

  test "Can delete Disallowed Host by record" do
    {:ok, true} = Impl.NetworkRules.host_disallowed(~i"10.10.250.2")

    {:ok, disallowed_host_record} =
      Impl.NetworkRules.get_disallowed_host_record_by_host(~i"10.10.250.2")

    assert {:ok, :deleted} = Impl.NetworkRules.delete_disallowed_host(disallowed_host_record)
    assert {:ok, false} = Impl.NetworkRules.host_disallowed(~i"10.10.250.2")

    assert {:ok, :not_found} = Impl.NetworkRules.delete_disallowed_host(disallowed_host_record)
  end

  test "Can delete Disallowed Host by host IP address" do
    {:ok, true} = Impl.NetworkRules.host_disallowed(~i"10.10.250.3")

    assert {:ok, :deleted} = Impl.NetworkRules.delete_disallowed_host_addr(~i"10.10.250.3")
    assert {:ok, false} = Impl.NetworkRules.host_disallowed(~i"10.10.250.3")

    assert {:ok, :not_found} = Impl.NetworkRules.delete_disallowed_host_addr(~i"10.10.250.3")
  end

  test "Can retrieve Disallowed Host by record ID" do
    {:ok, true} = Impl.NetworkRules.host_disallowed(~i"10.123.123.3")

    {:ok, subject_rec} = Impl.NetworkRules.get_disallowed_host_record_by_host(~i"10.123.123.3")

    assert {:ok, test_rec} = Impl.NetworkRules.get_disallowed_host_record_by_id(subject_rec.id)

    assert test_rec.id == subject_rec.id
  end

  test "Can get Disallowed Host record by Host Address" do
    {:ok, true} = Impl.NetworkRules.host_disallowed(~i"10.123.123.3")

    assert {:ok, %Data.SystDisallowedHosts{}} =
             Impl.NetworkRules.get_disallowed_host_record_by_host(~i"10.123.123.3")
  end

  test "Can get Implied Applied Network Rule" do
    assert %{precedence: :implied, functional_type: :allow} =
             Impl.NetworkRules.get_applied_network_rule!(~i"10.130.130.1")
  end

  test "Can get Disallowed Applied Network Rule" do
    assert %{precedence: :disallowed, functional_type: :deny} =
             Impl.NetworkRules.get_applied_network_rule!(~i"10.123.123.1")
  end

  test "Can get Global Applied Network Rule" do
    assert {:ok, %{precedence: :global, functional_type: :allow}} =
             Impl.NetworkRules.get_applied_network_rule(~i"10.125.125.2")

    assert %{precedence: :global, functional_type: :deny} =
             Impl.NetworkRules.get_applied_network_rule!(~i"10.131.131.5")
  end

  test "Can get Owner Applied Network Rule" do
    {:ok, owner_id} = MsbmsSystInstanceMgr.get_owner_id_by_name("owner1")

    assert {:ok, %{precedence: :instance_owner, functional_type: :deny}} =
             Impl.NetworkRules.get_applied_network_rule(~i"10.128.128.1", nil, owner_id)

    assert %{precedence: :instance_owner, functional_type: :allow} =
             Impl.NetworkRules.get_applied_network_rule!(~i"10.128.128.2", nil, owner_id)
  end

  test "Can get Instance Applied Network Rule" do
    {:ok, instance_id} =
      MsbmsSystInstanceMgr.get_instance_id_by_name("app1_owner1_instance_types_std")

    assert {:ok, %{precedence: :instance, functional_type: :deny}} =
             Impl.NetworkRules.get_applied_network_rule(~i"10.126.126.2", instance_id)

    assert %{precedence: :instance, functional_type: :allow} =
             Impl.NetworkRules.get_applied_network_rule!(~i"10.126.126.1", instance_id)

    assert %{precedence: :instance, functional_type: :allow} =
             Impl.NetworkRules.get_applied_network_rule!(~i"10.126.126.10", instance_id)
  end
end
