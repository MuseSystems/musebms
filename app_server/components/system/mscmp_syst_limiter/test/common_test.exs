# Source File: common_test.exs
# Location:    musebms/app_server/components/system/mscmp_syst_limiter/test/common_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule CommonTest do
  @moduledoc false

  use LimiterTestCase, async: true

  alias MscmpSystLimiter.Impl.Common

  @moduletag :unit
  @moduletag :capture_log

  describe "time_scale_to_ms/1" do
    test "converts millisecond correctly" do
      assert Common.time_scale_to_ms(:millisecond) == 1
    end

    test "converts second correctly" do
      assert Common.time_scale_to_ms(:second) == 1_000
    end

    test "converts minute correctly" do
      assert Common.time_scale_to_ms(:minute) == 60_000
    end

    test "converts hour correctly" do
      assert Common.time_scale_to_ms(:hour) == 3_600_000
    end

    test "converts day correctly" do
      assert Common.time_scale_to_ms(:day) == 86_400_000
    end
  end

  describe "time_scale_to_ms/2" do
    test "converts milliseconds with time value" do
      assert Common.time_scale_to_ms(:millisecond, 500) == 500
      assert Common.time_scale_to_ms(:millisecond, 1) == 1
      assert Common.time_scale_to_ms(:millisecond, 1000) == 1000
    end

    test "converts seconds with time value" do
      assert Common.time_scale_to_ms(:second, 1) == 1_000
      assert Common.time_scale_to_ms(:second, 5) == 5_000
      assert Common.time_scale_to_ms(:second, 30) == 30_000
    end

    test "converts minutes with time value" do
      assert Common.time_scale_to_ms(:minute, 1) == 60_000
      assert Common.time_scale_to_ms(:minute, 5) == 300_000
      assert Common.time_scale_to_ms(:minute, 15) == 900_000
    end

    test "converts hours with time value" do
      assert Common.time_scale_to_ms(:hour, 1) == 3_600_000
      assert Common.time_scale_to_ms(:hour, 2) == 7_200_000
      assert Common.time_scale_to_ms(:hour, 24) == 86_400_000
    end

    test "converts days with time value" do
      assert Common.time_scale_to_ms(:day, 1) == 86_400_000
      assert Common.time_scale_to_ms(:day, 7) == 604_800_000
      assert Common.time_scale_to_ms(:day, 30) == 2_592_000_000
    end

    test "handles large time values" do
      # 1 year in milliseconds
      assert Common.time_scale_to_ms(:day, 365) == 31_536_000_000
      # 1 week in milliseconds
      assert Common.time_scale_to_ms(:hour, 168) == 604_800_000
    end

    test "raises error for zero time value" do
      assert_raise ArgumentError, "The time value must be greater than or equal to 1", fn ->
        Common.time_scale_to_ms(:second, 0)
      end
    end

    test "raises error for negative time value" do
      assert_raise ArgumentError, "The time value must be greater than or equal to 1", fn ->
        Common.time_scale_to_ms(:minute, -1)
      end

      assert_raise ArgumentError, "The time value must be greater than or equal to 1", fn ->
        Common.time_scale_to_ms(:hour, -10)
      end
    end

    test "function clause error for invalid time scale" do
      assert_raise FunctionClauseError, fn ->
        Common.time_scale_to_ms(:invalid_scale, 1)
      end

      assert_raise FunctionClauseError, fn ->
        Common.time_scale_to_ms("second", 1)
      end
    end
  end

  describe "decode_time_scale/1" do
    test "decodes valid time scale codes" do
      assert Common.decode_time_scale(1) == {:ok, :millisecond}
      assert Common.decode_time_scale(2) == {:ok, :second}
      assert Common.decode_time_scale(3) == {:ok, :minute}
      assert Common.decode_time_scale(4) == {:ok, :hour}
      assert Common.decode_time_scale(5) == {:ok, :day}
    end

    test "returns error for invalid codes" do
      assert {:error, {:time_scale_coding_error, message}} = Common.decode_time_scale(0)
      assert message =~ "Invalid time scale code 0"

      assert {:error, {:time_scale_coding_error, message}} = Common.decode_time_scale(6)
      assert message =~ "Invalid time scale code 6"

      assert {:error, {:time_scale_coding_error, message}} = Common.decode_time_scale(100)
      assert message =~ "Invalid time scale code 100"
    end

    test "returns error for negative codes" do
      assert {:error, {:time_scale_coding_error, message}} = Common.decode_time_scale(-1)
      assert message =~ "Invalid time scale code -1"

      assert {:error, {:time_scale_coding_error, message}} = Common.decode_time_scale(-10)
      assert message =~ "Invalid time scale code -10"
    end

    test "returns error for non-integer codes" do
      assert {:error, {:time_scale_coding_error, message}} = Common.decode_time_scale(1.5)
      assert message =~ "Invalid time scale code 1.5"

      assert {:error, {:time_scale_coding_error, message}} = Common.decode_time_scale("1")
      assert message =~ "Invalid time scale code \"1\""

      assert {:error, {:time_scale_coding_error, message}} = Common.decode_time_scale(:second)
      assert message =~ "Invalid time scale code :second"
    end
  end

  describe "encode_time_scale/1" do
    test "encodes valid time scales" do
      assert Common.encode_time_scale(:millisecond) == {:ok, 1}
      assert Common.encode_time_scale(:second) == {:ok, 2}
      assert Common.encode_time_scale(:minute) == {:ok, 3}
      assert Common.encode_time_scale(:hour) == {:ok, 4}
      assert Common.encode_time_scale(:day) == {:ok, 5}
    end

    test "returns error for invalid time scales" do
      assert {:error, {:time_scale_coding_error, message}} =
               Common.encode_time_scale(:invalid)

      assert message =~ "Invalid time_scale :invalid"

      assert {:error, {:time_scale_coding_error, message}} =
               Common.encode_time_scale(:week)

      assert message =~ "Invalid time_scale :week"

      assert {:error, {:time_scale_coding_error, message}} =
               Common.encode_time_scale(:year)

      assert message =~ "Invalid time_scale :year"
    end

    test "returns error for non-atom time scales" do
      assert {:error, {:time_scale_coding_error, message}} =
               Common.encode_time_scale("second")

      assert message =~ "Invalid time_scale \"second\""

      assert {:error, {:time_scale_coding_error, message}} =
               Common.encode_time_scale(2)

      assert message =~ "Invalid time_scale 2"

      assert {:error, {:time_scale_coding_error, message}} =
               Common.encode_time_scale(nil)

      assert message =~ "Invalid time_scale nil"
    end
  end

  describe "encode/decode roundtrip" do
    test "all valid time scales roundtrip correctly" do
      time_scales = [:millisecond, :second, :minute, :hour, :day]

      for time_scale <- time_scales do
        {:ok, code} = Common.encode_time_scale(time_scale)
        {:ok, decoded_time_scale} = Common.decode_time_scale(code)
        assert decoded_time_scale == time_scale
      end
    end

    test "all valid codes roundtrip correctly" do
      codes = [1, 2, 3, 4, 5]

      for code <- codes do
        {:ok, time_scale} = Common.decode_time_scale(code)
        {:ok, encoded_code} = Common.encode_time_scale(time_scale)
        assert encoded_code == code
      end
    end
  end

  describe "integration with time calculations" do
    test "time_scale_to_ms works with encoded/decoded values" do
      # Test that encoded time scales work correctly with time_scale_to_ms
      {:ok, code} = Common.encode_time_scale(:minute)
      {:ok, time_scale} = Common.decode_time_scale(code)

      assert Common.time_scale_to_ms(time_scale) == 60_000
      assert Common.time_scale_to_ms(time_scale, 5) == 300_000
    end

    test "realistic rate limiting scenarios" do
      # 100 requests per minute
      {:ok, minute_code} = Common.encode_time_scale(:minute)
      {:ok, :minute} = Common.decode_time_scale(minute_code)
      window_ms = Common.time_scale_to_ms(:minute, 1)
      assert window_ms == 60_000

      # 1000 requests per hour
      {:ok, hour_code} = Common.encode_time_scale(:hour)
      {:ok, :hour} = Common.decode_time_scale(hour_code)
      window_ms = Common.time_scale_to_ms(:hour, 1)
      assert window_ms == 3_600_000

      # Daily API limits
      {:ok, day_code} = Common.encode_time_scale(:day)
      {:ok, :day} = Common.decode_time_scale(day_code)
      window_ms = Common.time_scale_to_ms(:day, 1)
      assert window_ms == 86_400_000
    end
  end

  describe "edge cases and boundary conditions" do
    test "minimum valid time value" do
      assert Common.time_scale_to_ms(:millisecond, 1) == 1
      assert Common.time_scale_to_ms(:second, 1) == 1_000
    end

    test "very large time values don't overflow" do
      # These should work without integer overflow issues
      large_days = Common.time_scale_to_ms(:day, 1000)
      assert is_integer(large_days)
      assert large_days > 0

      large_hours = Common.time_scale_to_ms(:hour, 10_000)
      assert is_integer(large_hours)
      assert large_hours > 0
    end

    test "boundary codes for decode" do
      # Test exact boundaries
      assert {:error, _} = Common.decode_time_scale(0)
      assert {:ok, :millisecond} = Common.decode_time_scale(1)
      assert {:ok, :day} = Common.decode_time_scale(5)
      assert {:error, _} = Common.decode_time_scale(6)
    end
  end
end
