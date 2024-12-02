# Source File: pg_error.ex
# Location:    musebms/components/system/mscmp_syst_db/lib/impl/pg_error.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystDb.Impl.PgError do
  @moduledoc false

  use Msutils.Guards

  alias MscmpSystDb.Types

  ##############################################################################
  #
  # Error Code Mapping & Documentation
  #
  #

  @error_codes [
    {
      "PM001",
      :msdata_disallowed_field_change,
      "A change was attempted on a field which does not allow changes."
    },
    {
      "PM002",
      :msdata_disallowed_operation,
      "An `INSERT`, `UPDATE`, or `DELETE` operation was attempted on a " <>
        "record which does not allow that operation."
    },
    {
      "PM003",
      :msdata_syst_defined,
      "Invalid change of a system defined record or field."
    },
    {
      "PM101",
      :msdata_logical_duplicate,
      "A logical duplicate was detected. This can happen when the business " <>
        "rules dictate a condition of uniqueness which cannot be readily " <>
        "implemented by a `UNIQUE` constraint."
    },
    {
      "PM102",
      :msdata_resource_exhausted,
      "A limited resource, such as a finite numbering sequence, has been " <>
        "exhausted."
    },
    {
      "PM103",
      :msdata_out_of_range,
      "Out of range values were detected."
    },
    {
      "PM104",
      :msdata_parent_child_mismatch,
      "A parent/child mismatch was detected."
    },
    {
      "PM105",
      :msdata_out_of_order_prereq,
      "Out of order pre-requisite establishment. This error is raised when " <>
        "an optional pre-requisite is established after records which would have " <>
        "to satisfy the pre-requisite have already been created."
    },
    {
      "PM106",
      :msdata_ineligible_deletion,
      "Ineligible for deletion. This error is raised when an attempt is made " <>
        "to delete a record or child of a record which is still either active " <>
        "or not purge eligible."
    },
    {
      "PM107",
      :msdata_invalid_data_change,
      "Invalid change for type. This error occurs when an operation or other " <>
        "data change is attempted where such a change is not allowed by the " <>
        "application's rules."
    },
    {
      "PM108",
      :msdata_invalid_state_change,
      "Invalid state change. This error occurs when an attempt is made to " <>
        "create a record or change the existing state of a record to an invalid " <>
        "state."
    },
    {
      "PM109",
      :msdata_out_of_order_deletion,
      "Out of order deletion. This error occurs when an attempt is made to " <>
        "delete a record or child of a record which would leave some other " <>
        "record or child of a record orphaned in some fashion."
    },
    {
      "PM110",
      :msdata_missing_parameter,
      "Missing parameter. This error occurs when a required parameter value " <>
        "is missing or was passed as a null value."
    }
  ]

  for {code, atom, _doc} <- @error_codes do
    defp code_to_atom(unquote(code)), do: unquote(atom)
  end

  defp code_to_atom(_), do: :database_error

  ##############################################################################
  #
  # get_error_code_docs
  #
  #

  @spec get_error_code_docs() :: binary()
  def get_error_code_docs do
    Enum.map_join(@error_codes, "\n\n", fn {code, atom, doc} ->
      "  * `#{inspect(atom)}` (#{inspect(code)}) - #{doc}"
    end)
  end

  ##############################################################################
  #
  # get_pg_exception
  #
  #

  @spec get_pg_exception(Exception.t()) :: Types.error_code() | Exception.t()
  def get_pg_exception(%Postgrex.Error{
        postgres: %{pg_code: <<"PM", _::binary-size(3)>> = code, message: msg}
      }) do
    {code_to_atom(code), msg}
  end

  def get_pg_exception(%Postgrex.Error{postgres: %{code: code}, message: msg})
      when is_reg_atom(code),
      do: {code, msg}

  def get_pg_exception(error), do: error
end
