# Source File: events_test.exs
# Location:    musebms/app_server/components/system/mscmp_syst_telemetry/test/events_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule EventsTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias MscmpSystTelemetry.Impl.Events

  @moduletag :unit

  describe "generate_events/3" do
    test "generates correct event names for log_debug events" do
      events =
        Events.generate_events(
          :test_component,
          [:database, :api],
          [:log_debug]
        )

      expected = [
        [:test_component, :database, :log_debug],
        [:test_component, :api, :log_debug]
      ]

      assert events == expected
    end

    test "generates correct event names for log_info events" do
      events =
        Events.generate_events(
          :test_component,
          [:worker],
          [:log_info]
        )

      expected = [[:test_component, :worker, :log_info]]
      assert events == expected
    end

    test "generates correct event names for log_warn events" do
      events =
        Events.generate_events(
          :test_component,
          [:general],
          [:log_warn]
        )

      expected = [[:test_component, :general, :log_warn]]
      assert events == expected
    end

    test "generates correct event names for log_error events" do
      events =
        Events.generate_events(
          :test_component,
          [:database],
          [:log_error]
        )

      expected = [[:test_component, :database, :log_error]]
      assert events == expected
    end

    test "generates correct event names for api_call_start events" do
      events =
        Events.generate_events(
          :my_component,
          [:api],
          [:api_call_start]
        )

      expected = [[:my_component, :api, :api_call, :start]]
      assert events == expected
    end

    test "generates correct event names for api_call_stop events" do
      events =
        Events.generate_events(
          :my_component,
          [:worker],
          [:api_call_stop]
        )

      expected = [[:my_component, :worker, :api_call, :stop]]
      assert events == expected
    end

    test "generates events for multiple categories with single event kind" do
      events =
        Events.generate_events(
          :test_component,
          [:database, :api, :worker],
          [:log_info]
        )

      expected = [
        [:test_component, :database, :log_info],
        [:test_component, :api, :log_info],
        [:test_component, :worker, :log_info]
      ]

      assert events == expected
    end

    test "generates events for single category with multiple event kinds" do
      events =
        Events.generate_events(
          :test_component,
          [:database],
          [:log_debug, :log_info, :log_error]
        )

      expected = [
        [:test_component, :database, :log_debug],
        [:test_component, :database, :log_info],
        [:test_component, :database, :log_error]
      ]

      assert events == expected
    end

    test "generates events for multiple categories with multiple event kinds" do
      events =
        Events.generate_events(
          :test_component,
          [:database, :api],
          [:log_info, :api_call_stop]
        )

      expected = [
        [:test_component, :database, :log_info],
        [:test_component, :database, :api_call, :stop],
        [:test_component, :api, :log_info],
        [:test_component, :api, :api_call, :stop]
      ]

      assert events == expected
    end

    test "generates events for all supported event kinds" do
      events =
        Events.generate_events(
          :test_component,
          [:general],
          [:log_debug, :log_info, :log_warn, :log_error, :api_call_start, :api_call_stop]
        )

      expected = [
        [:test_component, :general, :log_debug],
        [:test_component, :general, :log_info],
        [:test_component, :general, :log_warn],
        [:test_component, :general, :log_error],
        [:test_component, :general, :api_call, :start],
        [:test_component, :general, :api_call, :stop]
      ]

      assert events == expected
    end
  end

  describe "validate_categories/1" do
    test "returns :ok for valid categories" do
      assert Events.validate_categories([:database, :api]) == :ok
    end

    test "returns :ok for single category" do
      assert Events.validate_categories([:worker]) == :ok
    end

    test "returns error for empty list" do
      assert {:error, {:empty_categories, message}} = Events.validate_categories([])
      assert message =~ "At least one category must be provided"
    end

    test "returns error for non-list" do
      assert {:error, {:invalid_categories, message}} = Events.validate_categories(:not_a_list)
      assert message =~ "Categories must be a non-empty list of atoms"
    end
  end

  describe "validate_event_kinds/1" do
    test "returns :ok for valid event kinds" do
      assert Events.validate_event_kinds([:log_debug, :log_info]) == :ok
    end

    test "returns :ok for all valid event kinds" do
      valid_kinds = [
        :log_debug,
        :log_info,
        :log_warn,
        :log_error,
        :api_call_start,
        :api_call_stop
      ]

      assert Events.validate_event_kinds(valid_kinds) == :ok
    end

    test "returns error for empty list" do
      assert {:error, {:empty_event_kinds, message}} = Events.validate_event_kinds([])
      assert message =~ "At least one event kind must be provided"
    end

    test "returns error for invalid event kind" do
      assert {:error, {:invalid_event_kind, message}} =
               Events.validate_event_kinds([:invalid_event])

      assert message =~ "Event kind :invalid_event is unknown"
    end

    test "returns error for first invalid event kind in mixed list" do
      assert {:error, {:invalid_event_kind, message}} =
               Events.validate_event_kinds([:log_info, :bad_event, :api_call_stop])

      assert message =~ "Event kind :bad_event is unknown"
    end
  end
end
