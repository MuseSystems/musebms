# Source File: perm_functional_type.ex
# Location:    musebms/components/system/mscmp_syst_perms/lib/impl/perm_functional_type.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystPerms.Impl.PermFunctionalType do
  @moduledoc false

  use Msutils.Guards

  alias MscmpSystError.Types, as: ErrorTypes
  alias MscmpSystPerms.Types

  ##############################################################################
  #
  # update_perm_functional_type
  #
  #

  @spec update_perm_functional_type(
          Types.perm_functional_type_id() | Msdata.SystPermFunctionalTypes.t(),
          Types.perm_functional_type_params()
        ) ::
          {:ok, Msdata.SystPermFunctionalTypes.t()} | ErrorTypes.parsable_error()
  def update_perm_functional_type(perm_functional_type_id, perm_functional_type_params)
      when is_uuid(perm_functional_type_id) do
    case MscmpSystDb.get(Msdata.SystPermFunctionalTypes, perm_functional_type_id) do
      %Msdata.SystPermFunctionalTypes{} = perm_functional_type ->
        update_perm_functional_type(perm_functional_type, perm_functional_type_params)

      nil ->
        {:error,
         {:not_found,
          "The requested perm functional type was not found and could not be updated."}}
    end
  rescue
    error in Postgrex.Error -> {:error, MscmpSystDb.get_pg_exception(error)}
    error -> reraise(error, __STACKTRACE__)
  end

  def update_perm_functional_type(
        %Msdata.SystPermFunctionalTypes{} = perm_functional_type,
        perm_functional_type_params
      ) do
    perm_functional_type
    |> Msdata.SystPermFunctionalTypes.update_changeset(perm_functional_type_params)
    |> MscmpSystDb.update(returning: true)
    |> case do
      {:ok, perm} -> {:ok, perm}
      error -> {:error, error}
    end
  rescue
    error in Postgrex.Error -> {:error, MscmpSystDb.get_pg_exception(error)}
    error -> reraise(error, __STACKTRACE__)
  end
end
