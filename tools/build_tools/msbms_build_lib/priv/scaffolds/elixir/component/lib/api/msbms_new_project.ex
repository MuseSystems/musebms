# Source File: msbms_new_project.ex
# Location:    musebms/tools/build_tools/msbms_new_project/lib/api/msbms_new_project.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsNewProject do
  @external_resource "README.md"
  @moduledoc Path.join([__DIR__, "..", "..", "README.md"])
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  @doc """
  Hello world.

  ## Examples

      iex> MsbmsNewProject.hello()
      :world

  """
  def hello do
    :world
  end
end
