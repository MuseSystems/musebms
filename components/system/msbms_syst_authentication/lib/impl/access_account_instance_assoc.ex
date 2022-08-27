# Source File: access_account_instance_assoc.ex
# Location:    musebms/components/system/msbms_syst_authentication/lib/impl/access_account_instance_assoc.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystAuthentication.Impl.AccessAccountInstanceAssoc do
  import Ecto.Query
  import MsbmsSystUtils

  alias MsbmsSystAuthentication.Data
  alias MsbmsSystAuthentication.Types

  require Logger

  @moduledoc false

  @spec invite_access_account_to_instance(
          Types.access_account_id(),
          MsbmsSystInstanceMgr.Types.instance_id(),
          Types.credential_type_id(),
          Keyword.t()
        ) :: {:ok, Data.SystAccessAccountInstanceAssocs.t()} | {:error, MsbmsSystError.t()}
  def invite_access_account_to_instance(
        access_account_id,
        instance_id,
        credential_type_id,
        opts
      )
      when is_binary(access_account_id) and is_binary(instance_id) and
             is_binary(credential_type_id) do
    opts = resolve_options(opts, create_accepted: false, expiration_days: 30)

    now = DateTime.now!("Etc/UTC")

    invitation_issued = now

    access_granted = if opts[:create_accepted], do: now, else: nil

    invitation_expires =
      if !opts[:create_accepted],
        do: DateTime.add(now, opts[:expiration_days] * 24 * 60 * 60, :second),
        else: nil

    %{
      access_account_id: access_account_id,
      instance_id: instance_id,
      credential_type_id: credential_type_id,
      invitation_issued: invitation_issued,
      access_granted: access_granted,
      invitation_expires: invitation_expires
    }
    |> Data.SystAccessAccountInstanceAssocs.insert_changeset()
    |> MsbmsSystDatastore.insert!(returning: true)
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure inviting Access Account to Instance.",
          cause: error
        }
      }
  end
end
