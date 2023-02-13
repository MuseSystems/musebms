defmodule MscmpSystForms do
  alias MscmpSystForms.Impl
  alias MscmpSystForms.Types

  @external_resource "README.md"

  @moduledoc File.read!(Path.join([__DIR__, "..", "README.md"]))
end
