# Source File: types.ex
# Location:    musebms/app_server/components/system/mscmp_syst_utils/lib/api/types.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystUtilsString.Types do
  @moduledoc """
  This module defines the types used by the MscmpSystUtilsString library.
  """

  @typedoc """

  """
  @type token_sets :: :alphanum | :mixed_alphanum | :b32e | :b32c

  @typedoc """
  Ad-hoc token set type definition.
  """
  @type user_defined_tokens :: charlist()

  @typedoc """
  Acceptable token sets for use in generating random strings.
  """
  @type tokens :: token_sets | user_defined_tokens
end
