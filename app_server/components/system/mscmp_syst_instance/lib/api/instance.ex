# Source File: instance.ex
# Location:    musebms/app_server/components/system/mscmp_syst_instance/lib/api/instance.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystInstance.Instance do
  @moduledoc """
  Defines a behaviour and provides support functions for MscmpSystInstance
  compatible Instance modules.

  Instances are defined in both data configurations and application code.
  Each Instance consists of a top level Instance `Supervisor` and an optional
  set of Instance scoped services.

  The startup sequence of an Instance is as follows:

    1. The Instance `Supervisor` is started.

    2. The Instance scoped services are started under the Supervisor in
       order .

    3. A Instance Instances `DynamicSupervisor` is started.

    4. Any "start-able" Instances of the Instance are started, if the
       provided Instance startup options request Instance startup.

  """

  @doc """
  Retrieves service child specifications for a MscmpSystInstance compatible
  Instance.

  Details of the returned child specifications can be directed through the
  submission of a `t:Keyword.t/0` list of options.  The specific options
  accepted (or if options are accepted at all) are determined by each
  implementation of the behaviour.

  If the Instance defines no Instance scoped services to start, the
  callback will return `nil`.
  """
  @callback get_service_specs(Keyword.t() | nil) :: [Supervisor.child_spec()] | nil
end
