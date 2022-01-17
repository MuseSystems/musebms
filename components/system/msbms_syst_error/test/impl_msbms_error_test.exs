# Source File: impl_msbms_error_test.exs
# Location:    components/system/msbms_syst_error/test/impl_msbms_error_test.exs
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystError.ImplMsbmsErrorTest do
  use ExUnit.Case

  alias MsbmsSystError.Impl.MsbmsError

  @s0x02_descrip "Error description example."

  test "Get and verify errors list" do
    errors_list = MsbmsError.get_errors_list()

    assert Keyword.keyword?(errors_list)
    assert @s0x02_descrip = Keyword.get(errors_list, :S0X02)
  end

  test "Get description for error code" do
    assert @s0x02_descrip = MsbmsError.get_error_code_description(:S0X02)
  end

  test "Get root cause from error data" do
    test_err = %MsbmsSystError.Impl.MsbmsError{
                  code:     :S0X01,
                  tech_msg: "Outer error message",
                  module:   MsbmsSystError,
                  function: :get_root_cause,
                  cause:    %MsbmsSystError.Impl.MsbmsError{
                              code:     :S0X01,
                              tech_msg: "Intermediate error message",
                              module:   MsbmsSystError,
                              function: :get_root_cause,
                              cause:    %MsbmsSystError.Impl.MsbmsError{
                                          code:     :S0X02,
                                          tech_msg: "Root error message",
                                          module:   MsbmsSystError,
                                          function: :get_root_cause,
                                          cause:    {:error, "Example Error"},
                                        },
                            },
                }

    root_err = MsbmsError.get_root_cause(test_err)

    assert %MsbmsError{code: :S0X02, tech_msg: "Root error message"} = root_err

    assert {:error, "test error"} = MsbmsError.get_root_cause({:error, "test error"})

  end
end
