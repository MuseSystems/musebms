# Source File: mscmp_syst_error.ex
# Location:    musebms/app_server/components/system/mscmp_syst_error/lib/api/mscmp_syst_error.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystError do
  @external_resource "README.md"
  @moduledoc Path.join([__DIR__, "..", "..", "README.md"])
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  alias MscmpSystError.Impl

  @doc """
  Defines the callback for creating a new error of the implementing module.

  This function should be implemented by all modules using MscmpSystError.
  It creates a new error struct with the given kind, message, and options.

  ## Parameters

    * `kind` - The kind of error, which should be one of the kinds defined in
      the implementing module.

    * `message` - A string describing the error.

    * `opts` - A keyword list of additional options.

  ## Options

    * `:context` - A map containing additional context information for the error.

    * `:cause` - The cause of the error, which can be an exception, an error tuple,
      or any other term.

  ## Returns

  Returns a struct of the implementing module with the error details.
  """
  @callback new(kind :: atom(), message :: String.t(), opts :: keyword()) :: Exception.t()

  @spec __using__(keyword()) :: Macro.t()
  defmacro __using__(opts) do
    kinds = Keyword.fetch!(opts, :kinds)
    component = Keyword.fetch!(opts, :component)

    quote do
      @behaviour MscmpSystError

      @kinds unquote(Keyword.keys(kinds))
      @kinds_docs unquote(kinds)

      @component unquote(component)

      @typedoc """
      Represents the available Kinds of error allowed by this Error type.

      ## Available Kinds

      #{Enum.map_join(@kinds_docs, "\n", fn {kind, desc} -> "  * `#{inspect(kind)}` - #{desc}" end)}
      """
      @type kinds :: unquote(Enum.reduce(Keyword.keys(kinds), &{:|, [], [&1, &2]}))

      @type t :: %__MODULE__{
              kind: kinds(),
              message: String.t(),
              mserror: true,
              component: module(),
              context: MscmpSystError.Types.Context.t() | nil,
              cause: t() | Exception.t() | term() | nil
            }

      defexception [
        :kind,
        :message,
        mserror: true,
        component: @component,
        context: nil,
        cause: nil
      ]

      def exception(opts), do: new(opts[:kind], opts[:message], opts)

      @doc """
      Creates a new error struct with the given kind, message, and options.

      ## Parameters

        * `kind` - The kind of error, see `t:kinds/0` for the available Kinds.

        * `message` - A string describing the error.

        * `opts` - A keyword list of additional options.

      ## Options

        * `:context` - contextual information for better understanding the
          error.  If provided, the context should be of type
          `t:MscmpSystError.Types.Context.t/0`.

        * `:cause` - The cause of the error, which can be an exception, an error tuple,
          or any other term.

      ## Returns

      Returns a struct of this error type with the error details.
      """
      @impl true
      @spec new(kind :: kinds(), message :: String.t(), opts :: keyword()) :: t()
      def new(kind, message, opts \\ []) when kind in @kinds do
        %__MODULE__{
          kind: kind,
          message: message,
          context: Keyword.get(opts, :context),
          cause: Keyword.get(opts, :cause)
        }
      end

      defoverridable new: 3
    end
  end

  @doc section: :error_parsing
  @doc """
  Returns the root cause of an error object implementing the MscmpSystError behavior.

  The MscmpSystError exception handling framework allows for nested exceptions to be reported
  stack trace style from lower levels of the application where an exception was caused into higher
  levels of the application which enter a failure state due to the lower level root cause.

  This function will traverse the nesting and return the bottom most Error Struct. If some other
  object, such as a standard error tuple is passed to the function, the function will simply
  return that value.

  ## Examples
      iex> my_err = %ExampleError{
      ...>   kind: :example_error,
      ...>   message: "Outer error message",
      ...>   mserror: true,
      ...>   component: ExampleError,
      ...>   cause: %ExampleError{
      ...>     kind: :example_error,
      ...>     message: "Intermediate error message",
      ...>     mserror: true,
      ...>     component: ExampleError,
      ...>     cause: %ExampleError{
      ...>       kind: :example_error,
      ...>       message: "Root error message",
      ...>       mserror: true,
      ...>       component: ExampleError,
      ...>       cause: {:error, "Example Error"},
      ...>     },
      ...>   },
      ...> }
      iex> MscmpSystError.get_root_cause(my_err)
      %ExampleError{
        kind: :example_error,
        message: "Root error message",
        mserror: true,
        component: ExampleError,
        cause: {:error, "Example Error"}
      }

      iex> MscmpSystError.get_root_cause({:error, "Example Error"})
      {:error, "Example Error"}
  """
  @spec get_root_cause(any()) :: any()
  defdelegate get_root_cause(error), to: Impl.ErrorParser
end
