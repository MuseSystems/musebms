# Source File: syst_perm_functional_types.ex
# Location:    musebms/components/system/mscmp_syst_perms/lib/msdata/validators/syst_perm_functional_types.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystPerms.Msdata.Validators.SystPermFunctionalTypes do
  import Ecto.Changeset

  alias MscmpSystPerms.Msdata.Helpers
  alias MscmpSystPerms.Msdata.Validators
  alias MscmpSystPerms.Types

  @moduledoc false

  @spec update_changeset(
          Msdata.SystPermFunctionalTypes.t(),
          Types.perm_functional_type_params(),
          Keyword.t()
        ) ::
          Ecto.Changeset.t()
  def update_changeset(perm_functional_type, update_params, opts) do
    opts = MscmpSystUtils.resolve_options(opts, Helpers.OptionDefaults.defaults())

    perm_functional_type
    |> cast(update_params, [
      :display_name,
      :user_description
    ])
    |> validate_required([
      :display_name,
      :user_description
    ])
    |> Validators.General.validate_display_name(opts)
    |> optimistic_lock(:diag_row_version)
  end
end
