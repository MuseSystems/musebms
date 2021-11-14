
# Source File: instance.ex
# Location:    musebms/lib/msbms/system/data/instance.ex
# Project:     musebms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule Msbms.System.Data.Instance do
  use Ecto.Repo,
  otp_app: :msbms,
  adapter: Ecto.Adapters.Postgres
end
