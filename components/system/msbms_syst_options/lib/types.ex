# Source File: types.ex
# Location:    components/system/msbms_syst_options/lib/types.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystOptions.Types do
  @moduledoc """
  Provides the typespecs and related typing documentation for the
  MsbmsSystOptions module.
  """

  @typedoc """
  Instance classes are used to identify certain sorts of workloads or
  operational parameters of application instances.

  The valid types of Instance Class are:

    * `primary`- general purpose instance class which includes instances
    designated as 'production'.  In most cases, this is the only instance
    class that is required.

    * `linked`- designates a class of instances which are the children of a
    parent instance.  Typically these are non-production instances which are
    copies of their parent instance.

    * `demo`- instances which support application demonstration purposes.  Most
    installations will not require this type to be used.

    * `reserved`- other special use instances which don't fall under the other
    categories.  Typically there is no need to use this class.
  """
  @type instance_class :: String.t()
end
