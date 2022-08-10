# Source File: types.ex
# Location:    musebms/components/system/msbms_syst_rate_limiter/lib/types.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystRateLimiter.Types do
  @moduledoc """
  Defines public types for use with the MsbmsSystRateLimiter module.
  """

  @type counter_type() :: atom()

  @type counter_id() :: String.t()

  @type counter_name() :: String.t()

  #
  # Mnesia defined types (https://www.erlang.org/doc/man/mnesia.html#data-types)
  #

  @type table() :: atom()

  @type index_attr() :: atom() | non_neg_integer() | {atom()}

  @type create_option() ::
          {:access_mode, :read_write | :read_only}
          | {:attributes, [atom()]}
          | {:disc_copies, [node()]}
          | {:disc_only_copies, [node()]}
          | {:index, [index_attr()]}
          | {:load_order, non_neg_integer()}
          | {:majority, boolean()}
          | {:ram_copies, [node()]}
          | {:record_name, atom()}
          | {:snmp, snmp_struct :: term()}
          | {:storage_properties, [{backend :: module(), [backend_prop :: term()]}]}
          | {:type, :set | :ordered_set | :bag}
          | {:local_content, boolean()}
          | {:user_properties, :proplists.proplist()}

  @type t_result(res) :: {:atomic, res} | {:aborted, reason :: term()}
end
