# Source File: validators.ex
# Location:    musebms/app_server/components/system/mscmp_syst_session/lib/impl/msdata/syst_session/validators.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystSession.Impl.Msdata.SystSessions.Validators do
  @moduledoc false

  import Ecto.Changeset

  alias MscmpSystSession.Types

  @spec insert_changeset(Types.session_params()) :: Ecto.Changeset.t()
  def insert_changeset(insert_params) do
    %Msdata.SystSessions{}
    |> cast(insert_params, [:internal_name, :session_data, :session_expires])
    |> validate_required([:internal_name, :session_expires])
    |> unique_constraint(:internal_name, name: :syst_sessions_internal_name_udx)
  end

  @spec update_changeset(Msdata.SystSessions.t(), Types.session_params()) :: Ecto.Changeset.t()
  def update_changeset(session, update_params) do
    session
    |> cast(update_params, [:session_data, :session_expires])
    |> validate_required([:session_expires])
  end
end
