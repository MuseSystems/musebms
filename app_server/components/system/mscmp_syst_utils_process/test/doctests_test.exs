defmodule DoctestsTest do
  @moduledoc false

  use ProcessTestCase, async: true

  @moduletag :doctest

  doctest Msutils.Process
end
