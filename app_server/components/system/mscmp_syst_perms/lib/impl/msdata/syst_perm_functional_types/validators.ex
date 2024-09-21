# Source File: validators.ex
# Location:    musebms/app_server/components/system/mscmp_syst_perms/lib/impl/msdata/syst_perm_functional_types/validators.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystPerms.Impl.Msdata.SystPermFunctionalTypes.Validators do
  @moduledoc false

  import Ecto.Changeset

  alias MscmpSystPerms.Types

  @spec update_changeset(
          Msdata.SystPermFunctionalTypes.t(),
          Types.perm_functional_type_params(),
          Keyword.t()
        ) ::
          Ecto.Changeset.t()
  def update_changeset(perm_functional_type, update_params, opts) do
    perm_functional_type
    |> cast(update_params, [:display_name, :user_description])
    |> validate_required([:display_name])
    |> Msutils.Data.validate_display_name(opts)
    |> optimistic_lock(:diag_row_version)
    |> unique_constraint(:internal_name, name: :syst_perm_functional_types_internal_name_udx)
    |> unique_constraint(:display_name, name: :syst_perm_functional_types_display_name_udx)
  end
end
