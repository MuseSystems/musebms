defmodule MsbmsSystError.CiTestingTest do
  use ExUnit.Case

  test "This test should fail" do
    assert {:ok, 1} = {:error, 2}
  end
end
