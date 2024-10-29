# Source File: options_file.ex
# Location:    musebms/components/system/mscmp_syst_options/lib/impl/options_file.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystOptions.Impl.OptionsFile do
  @moduledoc false

  ######
  #
  # The OptionsFile module provides functions for retrieving a TOML file
  # containing the desired options settings.
  #
  ######

  @spec get_options(options_file_path :: String.t()) ::
          {:ok, map()} | {:error, term()}
  def get_options(options_file_path) when is_binary(options_file_path) do
    with {:ok, file_contents} <- File.read(options_file_path) do
      Toml.decode(file_contents, keys: :atoms)
    end
  end
end
