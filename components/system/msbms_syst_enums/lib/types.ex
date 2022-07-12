# Source File: types.ex
# Location:    components/system/msbms_syst_enums/lib/types.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystEnums.Types do
  @moduledoc """
  Types used by the Enums service module.
  """

  @typedoc """
  The valid forms of service name acceptable to identify the Enums service.

  Currently we expect the service name to be an atom, though we expect that any
  of a simple local name, the :global registry, or the Registry module to be
  used for service registration.  Any registry compatible with those options
  should also work.
  """
  @type service_name() :: atom() | {:via, module(), atom() | {atom(), atom()}}

  @typedoc """
  The expected form of the parameters used to start the Enums service.
  """
  @type enum_service_params() :: {service_name(), MsbmsSystDatastore.Types.context_id()}

  @typedoc """
  Identification of each unique Enum managed by the Enums Service instance.
  """
  @type enum_name() :: String.t()

  @typedoc """
  Identification of each unique Enum Functional Type that can be associated with
  an Enum.
  """
  @type enum_functional_type_name() :: String.t()

  @typedoc """
  Record ID type for the Enum Item record.
  """
  @type enum_item_id() :: binary()

  @typedoc """
  Identification of each unique Enum Value that can be associated with an Enum.
  """
  @type enum_item_name() :: String.t()

  @typedoc """
  A map definition describing what specific key/value pairs are available for
  passing as SystEnums changeset parameters.
  """
  @type enum_params() :: %{
          optional(:internal_name) => enum_name(),
          optional(:display_name) => String.t(),
          optional(:user_description) => String.t(),
          optional(:enum_items) => list(enum_item_params()),
          optional(:functional_types) => list(enum_functional_type_params())
        }

  @typedoc """
  A map definition describing what specific key/value pairs are available for
  passing as SystEnumFunctionalTypes changeset parameters.
  """
  @type enum_functional_type_params() :: %{
          optional(:enum_id) => Ecto.UUID.t(),
          optional(:internal_name) => enum_functional_type_name(),
          optional(:display_name) => String.t(),
          optional(:user_description) => String.t()
        }

  @typedoc """
  A map definition describing what specific key/value pairs are available for
  passing as SystEnumItems changeset parameters.
  """
  @type enum_item_params() :: %{
          optional(:enum_id) => Ecto.UUID.t(),
          optional(:functional_type_id) => Ecto.UUID.t(),
          optional(:functional_type_name) => enum_functional_type_name(),
          optional(:internal_name) => enum_item_name(),
          optional(:display_name) => String.t(),
          optional(:user_description) => String.t(),
          optional(:user_options) => map()
        }
end
