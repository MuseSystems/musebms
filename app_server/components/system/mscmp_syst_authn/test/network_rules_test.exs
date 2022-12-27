# Source File: network_rules_test.exs
# Location:    musebms/components/system/mscmp_syst_authn/test/network_rules_test.exs
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

  import Ecto.Query
  import IP, only: [sigil_i: 2]

  alias MscmpSystAuthn.Impl
  alias MscmpSystDb.DbTypes

  @moduletag :capture_log

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

    assert {:ok, %Msdata.SystDisallowedHosts{}} =
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
    {:ok, owner_id} = MscmpSystInstance.get_owner_id_by_name("owner1")

    assert {:ok, %{precedence: :instance_owner, functional_type: :deny}} =
             Impl.NetworkRules.get_applied_network_rule(~i"10.128.128.1", nil, owner_id)

    assert %{precedence: :instance_owner, functional_type: :allow} =
             Impl.NetworkRules.get_applied_network_rule!(~i"10.128.128.2", nil, owner_id)
  end

  test "Can get Instance Applied Network Rule" do
    {:ok, instance_id} =
      MscmpSystInstance.get_instance_id_by_name("app1_owner1_instance_types_std")

    assert {:ok, %{precedence: :instance, functional_type: :deny}} =
             Impl.NetworkRules.get_applied_network_rule(~i"10.126.126.2", instance_id)

    assert %{precedence: :instance, functional_type: :allow} =
             Impl.NetworkRules.get_applied_network_rule!(~i"10.126.126.1", instance_id)

    assert %{precedence: :instance, functional_type: :allow} =
             Impl.NetworkRules.get_applied_network_rule!(~i"10.126.126.10", instance_id)
  end

  test "Can create Global Network Rule" do
    new_ordering =
      from(gnr in Msdata.SystGlobalNetworkRules, select: max(gnr.ordering) |> coalesce(0))
      |> MscmpSystDb.one()
      |> then(fn current_ordering -> (current_ordering || 0) + 1 end)

    new_rule_params = %{
      ordering: new_ordering,
      functional_type: "allow",
      ip_host_or_network: ~i"10.150.150.100"
    }

    assert {:ok, created_rule} = Impl.NetworkRules.create_global_network_rule(new_rule_params)

    assert created_rule.ordering == new_rule_params.ordering
    assert created_rule.functional_type == new_rule_params.functional_type

    assert DbTypes.Inet.to_net_address(created_rule.ip_host_or_network) ==
             new_rule_params.ip_host_or_network
  end

  test "Can create Owner Network Rule" do
    {:ok, owner_id} = MscmpSystInstance.get_owner_id_by_name("owner6")

    new_ordering =
      from(onr in Msdata.SystOwnerNetworkRules,
        select: max(onr.ordering) |> coalesce(0),
        where: onr.owner_id == ^owner_id
      )
      |> MscmpSystDb.one()
      |> then(fn current_ordering -> (current_ordering || 0) + 1 end)

    new_rule_params = %{
      ordering: new_ordering,
      functional_type: "allow",
      ip_host_or_network: ~i"10.150.150.110"
    }

    assert {:ok, created_rule} =
             Impl.NetworkRules.create_owner_network_rule(owner_id, new_rule_params)

    assert created_rule.owner_id == owner_id
    assert created_rule.ordering == new_rule_params.ordering
    assert created_rule.functional_type == new_rule_params.functional_type

    assert DbTypes.Inet.to_net_address(created_rule.ip_host_or_network) ==
             new_rule_params.ip_host_or_network
  end

  test "Can create Instance Network Rule" do
    {:ok, instance_id} =
      MscmpSystInstance.get_instance_id_by_name("app1_owner6_instance_types_std")

    new_ordering =
      from(inr in Msdata.SystInstanceNetworkRules,
        select: max(inr.ordering) |> coalesce(0),
        where: inr.instance_id == ^instance_id
      )
      |> MscmpSystDb.one()
      |> then(fn current_ordering -> (current_ordering || 0) + 1 end)

    new_rule_params = %{
      ordering: new_ordering,
      functional_type: "deny",
      ip_host_range_lower: ~i"10.150.150.200",
      ip_host_range_upper: ~i"10.150.150.254"
    }

    assert {:ok, created_rule} =
             Impl.NetworkRules.create_instance_network_rule(instance_id, new_rule_params)

    assert created_rule.instance_id == instance_id
    assert created_rule.ordering == new_rule_params.ordering
    assert created_rule.functional_type == new_rule_params.functional_type

    assert DbTypes.Inet.to_net_address(created_rule.ip_host_range_lower) ==
             new_rule_params.ip_host_range_lower

    assert DbTypes.Inet.to_net_address(created_rule.ip_host_range_upper) ==
             new_rule_params.ip_host_range_upper
  end

  test "Can update Global Network Rule / Success Tuple" do
    global_rule =
      from(gnr in Msdata.SystGlobalNetworkRules, where: gnr.ordering == 5)
      |> MscmpSystDb.one!()

    update_params = %{
      ordering: 10,
      functional_type: "deny",
      ip_host_or_network: ~i"10.173.173.5"
    }

    assert {:ok, updated_rule} =
             Impl.NetworkRules.update_global_network_rule(global_rule.id, update_params)

    assert updated_rule.ordering == update_params.ordering
    assert updated_rule.functional_type == update_params.functional_type

    assert DbTypes.Inet.to_net_address(updated_rule.ip_host_or_network) ==
             update_params.ip_host_or_network
  end

  test "Can update Global Network Rule / Raise on Error" do
    global_rule =
      from(gnr in Msdata.SystGlobalNetworkRules, where: gnr.ordering == 6)
      |> MscmpSystDb.one!()

    update_params = %{
      ordering: 11,
      functional_type: "deny",
      ip_host_or_network: ~i"10.173.173.0/24"
    }

    assert updated_rule =
             Impl.NetworkRules.update_global_network_rule!(global_rule.id, update_params)

    assert updated_rule.ordering == update_params.ordering
    assert updated_rule.functional_type == update_params.functional_type

    assert DbTypes.Inet.to_net_address(updated_rule.ip_host_or_network) ==
             update_params.ip_host_or_network
  end

  test "Can update Owner Network Rule / Success Tuple" do
    {:ok, owner_id} = MscmpSystInstance.get_owner_id_by_name("owner5")

    owner_rule =
      from(onr in Msdata.SystOwnerNetworkRules,
        where: onr.owner_id == ^owner_id and onr.ordering == 1
      )
      |> MscmpSystDb.one!()

    update_params = %{
      ordering: 3,
      functional_type: "allow",
      ip_host_or_network: ~i"10.172.172.0/24"
    }

    assert {:ok, updated_rule} =
             Impl.NetworkRules.update_owner_network_rule(owner_rule.id, update_params)

    assert updated_rule.ordering == update_params.ordering
    assert updated_rule.functional_type == update_params.functional_type

    assert DbTypes.Inet.to_net_address(updated_rule.ip_host_or_network) ==
             update_params.ip_host_or_network
  end

  test "Can update Owner Network Rule / Raise on Error" do
    {:ok, owner_id} = MscmpSystInstance.get_owner_id_by_name("owner5")

    owner_rule =
      from(onr in Msdata.SystOwnerNetworkRules,
        where: onr.owner_id == ^owner_id and onr.ordering == 2
      )
      |> MscmpSystDb.one!()

    update_params = %{
      ordering: 4,
      functional_type: "deny",
      ip_host_range_lower: ~i"10.170.170.200",
      ip_host_range_upper: ~i"10.171.171.254"
    }

    assert updated_rule =
             Impl.NetworkRules.update_owner_network_rule!(owner_rule.id, update_params)

    assert updated_rule.ordering == update_params.ordering
    assert updated_rule.functional_type == update_params.functional_type

    assert DbTypes.Inet.to_net_address(updated_rule.ip_host_range_lower) ==
             update_params.ip_host_range_lower

    assert DbTypes.Inet.to_net_address(updated_rule.ip_host_range_upper) ==
             update_params.ip_host_range_upper
  end

  test "Can update Instance Network Rule / Success Tuple" do
    {:ok, instance_id} =
      MscmpSystInstance.get_instance_id_by_name("app1_owner7_instance_types_std")

    instance_rule =
      from(inr in Msdata.SystInstanceNetworkRules,
        where: inr.instance_id == ^instance_id and inr.ordering == 1
      )
      |> MscmpSystDb.one!()

    update_params = %{
      ordering: 3,
      functional_type: "deny",
      ip_host_or_network: ~i"10.175.175.1"
    }

    assert {:ok, updated_rule} =
             Impl.NetworkRules.update_instance_network_rule(instance_rule.id, update_params)

    assert updated_rule.ordering == update_params.ordering
    assert updated_rule.functional_type == update_params.functional_type

    assert DbTypes.Inet.to_net_address(updated_rule.ip_host_or_network) ==
             update_params.ip_host_or_network
  end

  test "Can update Instance Network Rule / Raise on Error" do
    {:ok, instance_id} =
      MscmpSystInstance.get_instance_id_by_name("app1_owner7_instance_types_std")

    instance_rule =
      from(inr in Msdata.SystInstanceNetworkRules,
        where: inr.instance_id == ^instance_id and inr.ordering == 2
      )
      |> MscmpSystDb.one!()

    update_params = %{
      ordering: 4,
      functional_type: "allow",
      ip_host_or_network: ~i"10.175.175.2"
    }

    assert updated_rule =
             Impl.NetworkRules.update_instance_network_rule!(instance_rule.id, update_params)

    assert updated_rule.ordering == update_params.ordering
    assert updated_rule.functional_type == update_params.functional_type

    assert DbTypes.Inet.to_net_address(updated_rule.ip_host_or_network) ==
             update_params.ip_host_or_network
  end

  test "Can get Global Network Rule / Success Tuple" do
    global_rule =
      from(gnr in Msdata.SystGlobalNetworkRules, where: gnr.ordering == 2)
      |> MscmpSystDb.one!()

    assert {:ok, test_rule} = Impl.NetworkRules.get_global_network_rule(global_rule.id)

    assert test_rule.ordering == global_rule.ordering
    assert test_rule.functional_type == global_rule.functional_type
    assert test_rule.ip_host_or_network == global_rule.ip_host_or_network
    assert test_rule.ip_host_range_lower == global_rule.ip_host_range_lower
    assert test_rule.ip_host_range_upper == global_rule.ip_host_range_upper
  end

  test "Can get Global Network Rule / Raise on Error" do
    global_rule =
      from(gnr in Msdata.SystGlobalNetworkRules, where: gnr.ordering == 2)
      |> MscmpSystDb.one!()

    assert test_rule = Impl.NetworkRules.get_global_network_rule!(global_rule.id)

    assert test_rule.ordering == global_rule.ordering
    assert test_rule.functional_type == global_rule.functional_type
    assert test_rule.ip_host_or_network == global_rule.ip_host_or_network
    assert test_rule.ip_host_range_lower == global_rule.ip_host_range_lower
    assert test_rule.ip_host_range_upper == global_rule.ip_host_range_upper
  end

  test "Can get Owner Network Rule / Success Tuple" do
    {:ok, owner_id} = MscmpSystInstance.get_owner_id_by_name("owner1")

    owner_rule =
      from(onr in Msdata.SystOwnerNetworkRules,
        where: onr.owner_id == ^owner_id and onr.ordering == 2
      )
      |> MscmpSystDb.one!()

    assert {:ok, test_rule} = Impl.NetworkRules.get_owner_network_rule(owner_rule.id)

    assert test_rule.owner_id == owner_rule.owner_id
    assert test_rule.ordering == owner_rule.ordering
    assert test_rule.functional_type == owner_rule.functional_type
    assert test_rule.ip_host_or_network == owner_rule.ip_host_or_network
    assert test_rule.ip_host_range_lower == owner_rule.ip_host_range_lower
    assert test_rule.ip_host_range_upper == owner_rule.ip_host_range_upper
  end

  test "Can get Owner Network Rule / Raise on Error" do
    {:ok, owner_id} = MscmpSystInstance.get_owner_id_by_name("owner1")

    owner_rule =
      from(onr in Msdata.SystOwnerNetworkRules,
        where: onr.owner_id == ^owner_id and onr.ordering == 3
      )
      |> MscmpSystDb.one!()

    assert test_rule = Impl.NetworkRules.get_owner_network_rule!(owner_rule.id)

    assert test_rule.owner_id == owner_rule.owner_id
    assert test_rule.ordering == owner_rule.ordering
    assert test_rule.functional_type == owner_rule.functional_type
    assert test_rule.ip_host_or_network == owner_rule.ip_host_or_network
    assert test_rule.ip_host_range_lower == owner_rule.ip_host_range_lower
    assert test_rule.ip_host_range_upper == owner_rule.ip_host_range_upper
  end

  test "Can get Instance Network Rule / Success Tuple" do
    {:ok, instance_id} =
      MscmpSystInstance.get_instance_id_by_name("app1_owner1_instance_types_std")

    instance_rule =
      from(inr in Msdata.SystInstanceNetworkRules,
        where: inr.instance_id == ^instance_id and inr.ordering == 3
      )
      |> MscmpSystDb.one!()

    assert {:ok, test_rule} = Impl.NetworkRules.get_instance_network_rule(instance_rule.id)

    assert test_rule.instance_id == instance_rule.instance_id
    assert test_rule.ordering == instance_rule.ordering
    assert test_rule.functional_type == instance_rule.functional_type
    assert test_rule.ip_host_or_network == instance_rule.ip_host_or_network
    assert test_rule.ip_host_range_lower == instance_rule.ip_host_range_lower
    assert test_rule.ip_host_range_upper == instance_rule.ip_host_range_upper
  end

  test "Can get Instance Network Rule / Raise on Error" do
    {:ok, instance_id} =
      MscmpSystInstance.get_instance_id_by_name("app1_owner1_instance_types_std")

    instance_rule =
      from(inr in Msdata.SystInstanceNetworkRules,
        where: inr.instance_id == ^instance_id and inr.ordering == 4
      )
      |> MscmpSystDb.one!()

    assert test_rule = Impl.NetworkRules.get_instance_network_rule!(instance_rule.id)

    assert test_rule.instance_id == instance_rule.instance_id
    assert test_rule.ordering == instance_rule.ordering
    assert test_rule.functional_type == instance_rule.functional_type
    assert test_rule.ip_host_or_network == instance_rule.ip_host_or_network
    assert test_rule.ip_host_range_lower == instance_rule.ip_host_range_lower
    assert test_rule.ip_host_range_upper == instance_rule.ip_host_range_upper
  end

  test "Can delete Global Network Rule / Success Tuple" do
    global_rule_id =
      from(gnr in Msdata.SystGlobalNetworkRules, where: gnr.ordering == 7, select: gnr.id)
      |> MscmpSystDb.one!()

    assert :ok = Impl.NetworkRules.delete_global_network_rule(global_rule_id)

    assert false ==
             from(gnr in Msdata.SystGlobalNetworkRules,
               where: gnr.id == ^global_rule_id,
               select: gnr.id
             )
             |> MscmpSystDb.exists?()
  end

  test "Can delete Global Network Rule / Raise on Error" do
    global_rule_id =
      from(gnr in Msdata.SystGlobalNetworkRules, where: gnr.ordering == 8, select: gnr.id)
      |> MscmpSystDb.one!()

    assert :ok = Impl.NetworkRules.delete_global_network_rule!(global_rule_id)

    assert false ==
             from(gnr in Msdata.SystGlobalNetworkRules,
               where: gnr.id == ^global_rule_id,
               select: gnr.id
             )
             |> MscmpSystDb.exists?()
  end

  test "Can delete Owner Network Rule / Success Tuple" do
    {:ok, owner_id} = MscmpSystInstance.get_owner_id_by_name("owner6")

    owner_rule_id =
      from(onr in Msdata.SystOwnerNetworkRules,
        where: onr.owner_id == ^owner_id and onr.ordering == 1,
        select: onr.id
      )
      |> MscmpSystDb.one!()

    assert :ok = Impl.NetworkRules.delete_owner_network_rule(owner_rule_id)

    assert false ==
             from(onr in Msdata.SystOwnerNetworkRules,
               where: onr.id == ^owner_rule_id,
               select: onr.id
             )
             |> MscmpSystDb.exists?()
  end

  test "Can delete Owner Network Rule / Raise on Error" do
    {:ok, owner_id} = MscmpSystInstance.get_owner_id_by_name("owner6")

    owner_rule_id =
      from(onr in Msdata.SystOwnerNetworkRules,
        where: onr.owner_id == ^owner_id and onr.ordering == 2,
        select: onr.id
      )
      |> MscmpSystDb.one!()

    assert :ok = Impl.NetworkRules.delete_owner_network_rule!(owner_rule_id)

    assert false ==
             from(onr in Msdata.SystOwnerNetworkRules,
               where: onr.id == ^owner_rule_id,
               select: onr.id
             )
             |> MscmpSystDb.exists?()
  end

  test "Can delete Instance Network Rule / Success Tuple" do
    {:ok, instance_id} =
      MscmpSystInstance.get_instance_id_by_name("app1_owner8_instance_types_std")

    instance_rule_id =
      from(inr in Msdata.SystInstanceNetworkRules,
        where: inr.instance_id == ^instance_id and inr.ordering == 1,
        select: inr.id
      )
      |> MscmpSystDb.one!()

    assert :ok = Impl.NetworkRules.delete_instance_network_rule(instance_rule_id)

    assert false ==
             from(inr in Msdata.SystInstanceNetworkRules,
               where: inr.id == ^instance_rule_id,
               select: inr.id
             )
             |> MscmpSystDb.exists?()
  end

  test "Can delete Instance Network Rule / Raise on Error" do
    {:ok, instance_id} =
      MscmpSystInstance.get_instance_id_by_name("app1_owner8_instance_types_std")

    instance_rule_id =
      from(inr in Msdata.SystInstanceNetworkRules,
        where: inr.instance_id == ^instance_id and inr.ordering == 2,
        select: inr.id
      )
      |> MscmpSystDb.one!()

    assert :ok = Impl.NetworkRules.delete_instance_network_rule!(instance_rule_id)

    assert false ==
             from(inr in Msdata.SystInstanceNetworkRules,
               where: inr.id == ^instance_rule_id,
               select: inr.id
             )
             |> MscmpSystDb.exists?()
  end
end
