# Source File: changeset_helpers.ex
# Location:    components/system/msbms_syst_instance_mgr/lib/impl/changeset_helpers.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystInstanceMgr.Impl.ChangesetHelpers do
  import Ecto.Changeset

  @moduledoc false

  @default_min_internal_name_length 6
  @default_max_internal_name_length 64

  @default_min_display_name_length 6
  @default_max_display_name_length 64

  # Resolve user provided options to a complete set of options by filling gaps
  # with pre-defined defaults.
  #
  # Allows the changeset function to resolve defaults that are used to
  # parameterize other validations.   We do that resolution in the changeset
  # function directly so we're only doing the user/default resolution once for
  # a changeset.
  @spec resolve_options(Keyword.t()) :: Keyword.t()
  def resolve_options(opts_given) do
    opts_default = [
      min_internal_name_length: @default_min_internal_name_length,
      max_internal_name_length: @default_max_internal_name_length,
      min_display_name_length: @default_min_display_name_length,
      max_display_name_length: @default_max_display_name_length
    ]

    Keyword.merge(opts_given, opts_default, fn _k, v1, _v2 -> v1 end)
  end

  # Validate the internal_name key for the changeset.
  #
  # Options:
  # min_internal_name_length - Sets the minimum grapheme length of internal_name
  #                            values.
  #
  # max_internal_name_length - Sets the maximum grapheme length of internal_name
  #                            values.
  @spec validate_internal_name(Ecto.Changeset.t(), Keyword.t()) :: Ecto.Changeset.t()
  def validate_internal_name(changeset, opts) do
    opts = resolve_options(opts)

    changeset
    |> validate_required(:internal_name)
    |> validate_length(:internal_name,
      min: opts[:min_internal_name_length],
      max: opts[:max_internal_name_length]
    )
    |> unique_constraint(:internal_name)
  end

  # Validate the display_name key for the changeset.
  #
  # Options:
  # min_display_name_length - Sets the minimum grapheme length of display_name
  #                           values.
  #
  # max_display_name_length - Sets the maximum grapheme length of display_name
  #                           values.
  @spec validate_display_name(Ecto.Changeset.t(), Keyword.t()) :: Ecto.Changeset.t()
  def validate_display_name(changeset, opts) do
    changeset
    |> validate_required(:display_name)
    |> validate_length(:display_name,
      min: opts[:min_display_name_length],
      max: opts[:max_display_name_length]
    )
    |> unique_constraint(:display_name)
  end
end
