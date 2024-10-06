# Source File: example_error.ex
# Location:    musebms/components/system/mscmp_syst_error/test/support/example_error.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule ExampleError do
  @moduledoc false

  use MscmpSystError, kinds: [example_error: "Example error"], component: __MODULE__
end
