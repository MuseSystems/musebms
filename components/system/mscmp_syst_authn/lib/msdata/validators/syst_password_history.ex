# Source File: syst_password_history.ex
# Location:    musebms/components/system/mscmp_syst_authn/lib/msdata/validators/syst_password_history.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystAuthn.Msdata.Validators.SystPasswordHistory do
  import Ecto.Changeset

  alias MscmpSystAuthn.Types

  @moduledoc false

  @spec insert_changeset(Types.access_account_id(), String.t()) :: Ecto.Changeset.t()
  def insert_changeset(access_account_id, credential_data)
      when is_binary(access_account_id) and is_binary(credential_data) do
    %Msdata.SystPasswordHistory{}
    |> cast(%{access_account_id: access_account_id, credential_data: credential_data}, [
      :access_account_id,
      :credential_data
    ])
    |> validate_required([:access_account_id, :credential_data])
  end
end