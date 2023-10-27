# Source File: validators.ex
# Location:    musebms/app_server/components/system/mscmp_syst_mcp_perms/lib/impl/msdata/syst_access_account_perm_role_assigns/validators.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystMcpPerms.Impl.Msdata.SystAccessAccountPermRoleAssigns.Validators do
  @moduledoc false

  import Ecto.Changeset

  alias MscmpSystMcpPerms.Types

  @spec insert_changeset(Types.access_account_perm_role_params()) :: Ecto.Changeset.t()
  def insert_changeset(insert_params) do
    %Msdata.SystAccessAccountPermRoleAssigns{}
    |> cast(insert_params, [:access_account_id, :perm_role_id])
    |> validate_required([:access_account_id, :perm_role_id])
    |> foreign_key_constraint(:access_account_id,
      name: :syst_access_account_perm_role_assigns_access_account_fk
    )
    |> foreign_key_constraint(:perm_role_id,
      name: :syst_access_account_perm_role_assigns_perm_role_fk
    )
    |> unique_constraint([:access_account_id, :perm_role_id],
      name: :syst_access_account_perm_role_assigns_udx
    )
  end
end
