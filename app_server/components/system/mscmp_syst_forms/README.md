# MscmpSystForms - User Interface Forms & Components

The `MscmpSystForms` module provides a standard methodology for authoring
application user interface forms in support of business systems development.

> #### `use MscmpSystForms` {: .info}
>
> When you `use MscmpSystForms`, the MscmpSystForms module will set `@behaviour
> MscmpSystForms` and the following functions will be created for the using
> module:
>
>  * `update_button_state/3`
>  * `start_processing_override/2`
>  * `finish_processing_override/2`
>  * `update_display_data/3`
>  * `get_component_info/1`
>
> Documentation for these functions is available in the module and they are
> simply delegates to the same functions (give or take some arity) in
> `MscmpSystForms`.

## Foundational Ideas

At the heart of our methodology and support are several key ideas presented
here.

> #### On "Forms" {: .neutral}
>
> One thing to be mindful of as you read this section and the documentation
> generally is our use of the word "Form".  In this documentation we will more
> often use the word "Form" in the more generic sense of a user interface to a
> particular subject or feature than to refer to a specific Form Component
> or something like an HTML form; we will use the word in that manner as well and
> hopefully context should make clear which sense we mean.

#### Definitions vs. Rendering

A "Form" conforming to the `MscmpSystForms` standard will be defined in two
distinct parts:

  * __Definitional Concerns__

    Our forms may be complex and include a variety of both informational and
    input fields (elements) to which different users will have different
    permission based entitlements.  Additionally, some element properties, such
    as labels, may appear not just along side the element in the user interface
    but also in tool tips, quick help pages and the like. Some properties, such
    as permissions or even some runtime display properties can easily be made
    inheritable from parent elements to child elements; naturally, the idea of
    virtual elements can be useful in building such hierarchies as well.

    Having a place to define both these static elements and the inheritance
    hierarchies between elements without necessarily being coupled to the layout
    has advantages.  We can create a cleaner definition of these properties
    while reducing the redundancies that defining these attributes in the
    context of page layout concerns could force on us as well as reducing the
    noise that display related attributes would necessarily force on us.

  * __Rendering Concerns__

    All forms must ultimately be laid out for rendering as the user interface
    and this area of concern deals with the issues of laying out our form
    elements.

The truth is that the "Rendering Concerns" are really the typical user interface
development activities (web or otherwise) that most front end developers will
think about and it is the "Definitional Concerns" which we are adding to that
process.

#### Form Data

It is not uncommon to closely couple database Ecto schema definitions with the
presentation and management forms, using the Ecto database schema to directly
drive the user interface forms.  The problem is that it can force unnatural
compromises to either the database structure (assuming that the Ecto Schemas are
representative of the underlying table structures) or the user interface forms
or both.

In our model we view both the database structure and the user interface design
as first class concerns and as such our standard is to not directly use Ecto
Schemas which define database data to also back forms.  We create independent
Ecto ["Embedded Schemas"](https://hexdocs.pm/ecto/embedded-schemas.html) to back
the forms specifically.  It absolutely happens that there can be form schemas
and database schemas with high degrees of similarity, but by setting the
expectation that we will always have an Embedded Schema defined to back the form
ensures that the development of the form avoids the aforementioned conflicts and
compromises.

Any given form will also have three senses of its data, each of which may differ
from each other enough that we track the data for all three purposes:

  * __Original Data__

    This is the data which a form initializes with.  When creating new records,
    this will either be empty or populated with the default values defined as
    the starting place for any new records.  For viewing or editing existing
    data records, this value will be the data as loaded from the database.  As
    the user interacts with the form, these original data values will not
    change, always reflecting the starting point with which the form was
    initialized.

    While not always useful we can use the original data for fallback/reset
    purposes, to display changes (e.g. percentage changed) relative to the
    starting data, and similar such purposes.

    In the form's assigns we represent this using the form backing `Ecto`
    embedded schema struct which can be passed as the "data" expected by
    `Ecto.Changeset` validation functions.  This data is kept by the view
    including all values regardless of user permissions to see or alter those
    values.

  * __Current Data__

    The current state of the data, including any changes made by the user or
    system as they interact with the form, but prior to those changes being
    committed to the database.  The starting point of this data when the form
    initializes is typically the same as the Original Data.

    As the user interacts with the form, the current data is updated to reflect
    changes.  We usually store this data in the form's assigns as a map as we
    can pass this directly to the data validation functions (`Ecto.Changeset`
    based) as needed.

    The current data includes all form data regardless of the user's permissions
    to view or edit that data.

  * __Display Data__

    A representation of the data for the purposes of display to the user in the
    form.  The data values in Display Data are the same as those in Current Data
    except they are filtered by the user's permissions for data visibility.

    Display Data is stored in the view's assigns as a `t:Phoenix.HTML.Form.t/0`
    struct so that it can be accessed directly by the LiveView for rendering.

#### Working with Phoenix

The most common use case for `MscmpSystForms` is for facilitating Phoenix based
web and external API user interface development.  To understand how
`MscmpSystForms` fits into the Phoenix development model it's important to
understand certain assumptions we make about the role of Phoenix in our broader
application development paradigm.

> #### Important {: .warning}
>
> Our thinking and approach to working with Phoenix is not the conventional or
> generally accepted approach in many ways.  Use caution and understand the
> trade-offs when evaluating our work in this regard.

Our development model takes the stance that Phoenix is not the application, but
the user interface layer.  That layer brings together a lot of dependencies to
deliver services, but those dependencies are independently developed as separate
Elixir/OTP applications and could be used (in theory) in other contexts.

As such our Phoenix application only deals with the presentation of the user
interface and wiring that user interface to the actual business/domain logic
written elsewhere.  In the process some elements which by convention has certain
roles within typical Phoenix application development are repurposed to serve our
needs better.

## Developing Forms

With our Foundational Ideas having been discussed, we now move on to looking how
this translates into form development.

#### Source Organization & File Roles

Starting with a standard Phoenix application, to which `MscmpSystForms` has been
added as a dependency, we will have two basic directories (or applications in
the case where the Phoenix project is initialized as an umbrella project):
`my_app`, `my_app_web`.  In typical Phoenix applications the web based user
interface including views and controllers are built in the `my_app_web`
directory and the business/domain logic (i.e. "contexts")  resides in the
`my_app` directory.  We adopt the directories created by `mix phx.new`, but we
change their purpose:

  * __my_app_web__

    Hosts view related code.  Controller like code is discouraged here.

  * __my_app__:

    Hosts controller like logic.  Business/Domain Logic is discouraged here and
    should be developed in external Elixir Projects and included as dependencies
    in the Phoenix application.

Using these directories, and assuming our application has one form (`my_form`),
we will create the following basic file structure for our form's source code:

```
my_app_web
└── lib
    └── my_app_web
        └── live
            ├── my_form_live.ex
            └── my_form_live.html.heex

my_app
└── lib
    └── msform
        ├── my_form
        │   ├── actions.ex
        │   ├── data.ex
        │   ├── definitions.ex
        │   └── types.ex
        └── my_form.ex
```
> #### Note {: .neutral}
>
> The example directory structure above has been simplified to focus on those
> entries important to understanding the `MscmpSystForms` development model.
> Other files and directories which are standard for Phoenix development and
> which would be present but unaltered under our model have been excluded from
> the example listings.

* __my_app_web__

  In the `my_app_web` example listing the path `my_app_web/lib/my_app_web/live`
  is the standard Phoenix pathing for `Phoenix.LiveView` pages.  While we do
  make some assumption changes to Phoenix standard practices in regard to what
  gets done in this directory, those changes are minor and really a matter of
  convention.

  #### Files

    * `my_form_live.html.heex`

      this file is a typical Phoenix LiveView `Heex` file.  The only difference
      from standard Phoenix Heex development is that
      `MscmpSystForms.WebComponents` will be used as a source of components
      rather than the `CoreComponents` module which comes with Phoenix (though
      it is available).

    * `my_form_live.ex`

      this file is the typical LiveView controller file
      which backs the LiveView which is home to the LiveView's `mount/3`,
      `handle_event/3`, and `handle_info/2` functions.  The difference under the
      `MscmpSystForms` model is that we typically code much less logic directly
      in this file allowing that logic to exist in the `my_app` directory
      hierarchy.

      Therefore this file is limited to two roles: 1) mapping LiveView events to
      controller level logic in the `my_app` code; and 2) values which directly
      become display issues in the web interface; for example text strings for
      flash messages related to validation failures might be coded here since
      we're effectively still in the "view" layer per our definitions.

* __my_app__

  Under our methodology we make the greatest departures from typical Phoenix
  development in this directory.  In typical Phoenix development practice this
  directory is the home of the business/domain logic, the "model".  For us,
  however, this is our controller layer, but even more importantly it is where
  we deal with the "Definitional Concerns" discussed earlier and which is unique
  to `MscmpSystForms` based forms.

  #### Sub-directories & Files

    * `msform`

      This directory holds source files and sub-directories for defining form
      data, defining the abstract configuration of form components, and includes
      our form controller logic which calls our externally defined business
      logic in response to user interactions.

      For each form, we define a single Elixir source file named after the name
      of the form it exists to support.  We also create a sub-directory also
      named after the form.

    * `msform/my_form.ex`

      This Elixir source file defines a single module in the `Msform` namespace
      which implements the `MscmpSystForms` behavior (typically with
      `use MscmpSystForms`).  This module also defines a struct of the form's
      backing data using `Ecto.Schema.embedded_schema/1` so that we can use the
      fully data mapping and validation capability of both Ecto and Phoenix
      forms.

      Finally this module also defines an API for the form which includes the
      implementation of the `MscmpSystForms` Behaviour callbacks and functions
      to expose other controller-like logic as appropriate to the forms specific
      needs.  Note that the API is typically delegating to specific source files
      and internal modules written in the `msform/my_form/*.ex` files.

    * `msform/my_form/actions.ex`

      This source file typically defines a single module for the form
      implementing the controller-like actions which are initiated from the
      user interface or other sources the form should respond to (e.g. PubSub
      messages).

    * `msform/my_form/data.ex`

      Typically defines a single module containing functions which implement
      form data validation via Changeset processing.

    * `msform/my_form/definitions.ex`

      This file contains a single module directed at resolving a form's
      "Definitional Concerns".  In this module we find the implementation of the
      `c:MscmpSystForms.get_form_config/0` and
      `c:MscmpSystForms.get_form_modes/0` functions.

    * `msform/my_form/types.ex`

      A module to define/document form specific typespecs.  Usually this will
      at least contain a type `parameters` for use in typespecs associated with
      Changeset processing.  Since functions like `Ecto.Changeset.cast/4`
      require their 'params' argument to be represented as a map and since we
      know the possible valid structures of the map we can define a typespec to
      help documenting that structure.