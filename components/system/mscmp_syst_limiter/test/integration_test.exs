# Source File: integration_test.exs
# Location:    musebms/components/system/mscmp_syst_limiter/test/integration_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule IntegrationTest do
  use ExUnit.Case, async: false

  @moduletag :integration

  test "Step 1: Create Mnesia Table" do
    assert {:ok, _detail} = MscmpSystLimiter.init_rate_limiter()
  end

  test "Step 2: Can check a rate limit counter" do
    assert {:allow, 1} = MscmpSystLimiter.check_rate(:check_rate_test, "1", 60_000, 3)
    assert {:allow, 2} = MscmpSystLimiter.check_rate(:check_rate_test, "1", 60_000, 3)
    assert {:allow, 3} = MscmpSystLimiter.check_rate(:check_rate_test, "1", 60_000, 3)
    assert {:deny, 3} = MscmpSystLimiter.check_rate(:check_rate_test, "1", 60_000, 3)
  end

  test "Step 3: Can get check rate function" do
    assert test_rate = MscmpSystLimiter.get_check_rate_function(:rate_checker, 60_000, 3)

    assert is_function(test_rate)

    assert {:allow, 1} = test_rate.("1")
    assert {:allow, 2} = test_rate.("1")
    assert {:allow, 3} = test_rate.("1")
    assert {:deny, 3} = test_rate.("1")
  end

  test "Step 4: Can get counter info" do
    {:allow, 1} = MscmpSystLimiter.check_rate(:inspect_test, "2", 60_000, 3)

    assert {:ok, {count, count_remaining, ms_to_next_counter, created_at, updated_at}} =
             MscmpSystLimiter.inspect_counter(:inspect_test, "2", 60_000, 3)

    assert is_integer(count)
    assert count == 1
    assert is_integer(count_remaining)
    assert count_remaining == 2
    assert is_integer(ms_to_next_counter)
    assert is_integer(created_at)
    assert is_integer(updated_at)
  end

  test "Step 5: Can delete counters" do
    {:allow, 1} = MscmpSystLimiter.check_rate(:delete_test, "3", 60_000, 3)

    assert {:ok, 1} = MscmpSystLimiter.delete_counters(:delete_test, "3")
  end
end