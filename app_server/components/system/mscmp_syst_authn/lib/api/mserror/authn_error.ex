# Source File:  authn_error.ex
# Location:     musebms/app_server/components/system/mscmp_syst_authn/lib/api/mserror/authn_error.ex
# Project:      Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Mserror.AuthnError do
  @moduledoc false

  use MscmpSystError,
    component: MscmpSystAuthn,
    kinds: [
      authenticator_management: "Failure operating on Authenticator data.",
      authentication: "Failure operating on Authentication data.",
      account_code: "Failure operating on Account Code data.",
      access_account_data: "Failure operating on Access Account data.",
      access_account_instance_assoc_data:
        "Failure operating on Access Account Instance Assoc data.",
      password_rule_data: "Failure operating on Password Rule data.",
      network_rule_data: "Failure operating on Network Rule data.",
      enumeration_data: "Failure operating on Enumeration data.",
      service_management: "Failure performing a Service Management operation."
    ]
end
