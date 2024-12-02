# Source File: types.ex
# Location:    musebms/app_server/components/system/mscmp_syst_error/lib/api/types.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystError.Types do
  @moduledoc """
  This module defines the types used by the MscmpSystError module.
  """

  @typedoc """
  This type represents the various forms that errors can take which can be
  parsed into a MscmpSystError compliant exception struct.

  While it is true that this type effectively matches any value at all, its
  intention is to document the various forms which may result in different
  parsing logic and ultimately results.

  The following forms are supported:

    * `{:error, {:error, term()}}` - A nested error tuple is recursively parsed
      to remove the nesting and extract the underlying error.  Final processing
      will depend on the final form of the error once the nesting is removed.

    * `{:error, {code :: atom(), message :: String.t()}}` - In this form the
      error tuple contains an error code and a message.  The code becomes the
      `cause` value of the resulting exception struct and the message becomes
      the `message` value.  Many internal system errors are reported in this
      form.

    * `{:error, code :: atom()}` - In this form the error tuple contains only
      an error code.  The code becomes the `cause` value of the resulting
      exception struct and the message is simply set to a generic default
      message.  Many internal system errors are reported in this form.

    * `{:error, term()}` - In this form the error tuple contains an arbitrary
      term.  The term becomes the `cause` value of the resulting exception struct
      and the message is simply set to a generic default message.  This form is
      often found when a dependency or other third party library reports an
      error tuple.

    * `term()` - In this case we can't do any special parsing and the term will
      simply become the `cause` value of the resulting exception struct.
  """
  @type parsable_error() ::
          {:error, {:error, term()}}
          | {:error, {code :: atom(), message :: String.t()}}
          | {:error, code :: atom()}
          | {:error, term()}
          | term()

  @typedoc """
  This type represents the result of parsing an error result conforming to
  `t:parsable_error/0`.
  """
  @type parsed_error() :: {cause :: term(), message :: String.t() | nil}
end
