defmodule PlaceholderUnitTest do
  use InteractionTestCase, async: true

  @moduletag :unit
  @moduletag :capture_log

  test "Placeholder which does nothing" do
    assert true
  end
end
