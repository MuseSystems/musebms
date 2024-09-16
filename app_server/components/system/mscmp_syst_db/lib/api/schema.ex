# Source File: schema.ex
# Location:    musebms/app_server/components/system/mscmp_syst_db/lib/api/schema.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystDb.Schema do
  @moduledoc """
  Provides common attributes for use by most application Ecto Schema instances.

  Chiefly, we ensure that the primary and foreign keys are all of a common type.

  To use this module, simply add `use MscmpSystDb.Schema` in place of
  `use Ecto.Schema`.
  """
  @spec __using__(term()) :: Macro.t()
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      @primary_key {:id, :binary_id, autogenerate: false}
      @foreign_key_type :binary_id
    end
  end
end
