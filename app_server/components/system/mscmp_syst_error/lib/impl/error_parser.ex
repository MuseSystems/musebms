# Source File: error_parser.ex
# Location:    musebms/app_server/components/system/mscmp_syst_error/lib/impl/error_parser.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystError.Impl.ErrorParser do
  @moduledoc false

  alias MscmpSystError.Types

  ##############################################################################
  #
  # get_root_cause
  #
  #

  @spec get_root_cause(any()) :: any()
  def get_root_cause(%{__mserror__: true, cause: %_{__mserror__: true} = next_error}) do
    next_error
    |> get_root_cause()
  end

  def get_root_cause(last_error), do: last_error

  ##############################################################################
  #
  # parse_error
  #
  #

  @spec parse_error(Types.parsable_error()) :: Types.parsed_error()
  def parse_error(error), do: do_parse(error)

  defp do_parse({:error, {:error, _} = inner_error}), do: do_parse(inner_error)

  defp do_parse({:error, {code, message}}) when is_atom(code) and is_binary(message),
    do: {code, message}

  defp do_parse({:error, code}) when is_atom(code), do: {code, nil}

  defp do_parse({:error, term}), do: {term, nil}

  defp do_parse(term), do: {term, nil}
end
