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

  alias MscmpSystPerms.Types

  require Logger

  @spec update_perm_functional_type(
          Types.perm_functional_type_id() | Msdata.SystPermFunctionalTypes.t(),
          Types.perm_functional_type_params()
        ) ::
          {:ok, Msdata.SystPermFunctionalTypes.t()} | {:error, MscmpSystError.t()}
  def update_perm_functional_type(perm_functional_type_id, perm_functional_type_params)
      when is_binary(perm_functional_type_id) do
    MscmpSystDb.get!(Msdata.SystPermFunctionalTypes, perm_functional_type_id)
    |> update_perm_functional_type(perm_functional_type_params)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure updating Permission Functional Type by ID.",
         cause: error
       }}
  end

  def update_perm_functional_type(
        %Msdata.SystPermFunctionalTypes{} = perm_functional_type,
        perm_functional_type_params
      ) do
    perm_functional_type
    |> Msdata.SystPermFunctionalTypes.update_changeset(perm_functional_type_params)
    |> MscmpSystDb.update!(returning: true)
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure updating Permission Functional Type.",
         cause: error
       }}
  end
end
