defmodule MsbmsSystAuthenticationTest do
  use AuthenticationTestCase, async: true
  doctest MsbmsSystAuthentication

  test "greets the world" do
    assert MsbmsSystAuthentication.hello() == :world
  end
end
