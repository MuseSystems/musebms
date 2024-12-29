defmodule MscmpSystUtilsProcessTest do
  use ExUnit.Case
  doctest MscmpSystUtilsProcess

  test "greets the world" do
    assert MscmpSystUtilsProcess.hello() == :world
  end
end
