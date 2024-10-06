# MscmpSystError - Exception Handling Behaviour

<!-- MDOC !-->

MscmpSystError establishes a common framework for defining and handling errors.

MscmpSystError provides a structured way to define and handle errors within an
application. It defines a set of fields that errors should include, such as
`kind`, `message`, `context`, and `cause`. This standardization enables
consistent error handling and reporting across different parts of an
application.

To create a new Error type implemention, you can use the `use MscmpSystError`
macro in your module.

```elixir
defmodule Mserror.MyError do
  use MscmpSystError,
    kinds: [my_error: "`:my_error` Error Kind documentation"],
    component: ExampleComponent
end
```
## Options

The `use MscmpSystError` macro requires that the following options are provided:

* `:kinds` - A keyword list of error kinds, where the key is the atom
  representing the error kind, and the value is a string providing a
  documentation string for the error kind.

* `:component` - This is a reference to the Component where the error type is
  defined.  As errors may be propogated from lower level dependencies to higher
  level components, this value helps identify the origin of any given error.

Failing to provide these options will result in a compile time error.

> #### `use MscmpSystError` {: .info}
>
> When `use MscmpSystError` is called with the required options, it:
>
> 1. Implements the `MscmpSystError` behaviour.
>
> 2. Defines a `kinds` type based on the provided `:kinds` option.
>
> 3. Creates a struct with fields for `kind`, `message`, `mserror`, `component`,
>    `context`, and `cause`.
>
> 4. Implements `defexception` with the struct fields.
>
> 5. Defines an `exception/1` function that delegates to `new/3`.
>
> 6. Implements a `new/3` function that creates a new error struct with the
>    given kind, message, and options.