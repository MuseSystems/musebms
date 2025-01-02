defmodule ProcessTestCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  setup_all do
    test_processes = TestSupport.start_test_processes()
    {:ok, test_processes}
  end
end
