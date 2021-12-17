# Source File: utils.ex
# Location:    musebms/lib/msbms/system/data/utils.ex
# Project:     musebms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule Msbms.System.Data.Utils do
  @moduledoc """
  Provides some simple utility functions which may be used in different data management tasks.

  ## Scope of Usage
  These utilities are only expected to be used by Msbms.System.Data modules.
  """
  alias Msbms.System.Constants

  @doc """

  """
  @spec generate_password(binary, binary, binary) :: binary
  def generate_password(instance_code, dbident, dbsalt)
      when is_binary(instance_code) and is_binary(dbident) and is_binary(dbsalt) do
    :crypto.hash(:blake2b, instance_code <> dbident <> Constants.get(:dbident_salt) <> dbsalt)
    |> Base.encode64()
  end
end
