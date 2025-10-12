# Source File: component_config.ex
# Location:    musebms/app_server/components/system/mscmp_syst_forms/lib/api/types/component_config.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystForms.Types.ComponentConfig do
  @moduledoc """
  Defines the rendering configurations used by components at runtime.

  The `MscmpSystForms.get_render_configs/5` function returns
  a full form aggregate render configuration which is a combination of the
  developer created `t:MscmpSystForms.Types.FormConfig.t/0` values and various
  values determined at runtime such as the current form state, active
  processing overrides, and current user permissions.

  This would be called a "Render Time" concern/derived configuration.

  The ComponentConfig values created by `MscmpSystForms.get_render_configs/5`
  just described are passed to the view where each Web Component will respond to
  its ComponentConfig value in order to meet the then prevailing view
  requirements.

  > ### Note {: .info}
  > This struct will not typically be created or used directly by a developer
  > creating user forms.  In this sense this struct could be considered an
  > internal implementation concern which shouldn't be part of the public
  > documentation.  However, developers creating components which need to
  > participate in `MscmpSystForms` form processing will need to know how to
  > make their components respond to `ComponentConfig` values so we do include
  > it in the documentation here.
  """

  alias MscmpSystForms.Types

  defstruct form_id: nil,
            binding_id: nil,
            permission: nil,
            label: nil,
            label_link: nil,
            info: nil,
            button_state: nil,
            overrides: nil,
            modes: nil

  @typedoc """
  Defines the rendering configurations used by components at runtime.

  ## Attributes

    * `form_id` - identifies the user interface form element to which the
    component configuration will be applied.  Note that whereas
    `t:MscmpSystForms.Types.FormConfig.t/0` allows configurations of virtual or
    abstract components, these configurations will never appear as a
    `t:MscmpSystForms.Types.ComponentConfig.t/0` value.  Only concrete
    components with a `form_id` value are allowed to represented by component
    configurations.

    * `binding_id` - for user interface elements which display application data
    to identify the data field from which to draw values using this identifier.
    If the `binding_id` is `nil` then the element will not be bound to a field
    in the form's backing data.

    * `permission` - the identifier of the permission which determined may have
    changed the `modes` value which control element rendering.  This value will
    either be the permission set explicitly for field or that which the element
    inherited through its `MscmpSystForms.Types.FormConfig` parent.  This value
    may also be `nil` in which case permissions didn't influence the `modes`
    value because no permissions were defined to apply.

    * `label` - if set, this value will determine the label text for any Web
    Component which can display a label, such as
    `MscmpSystForms.WebComponents.msinput/1`.  If the component's `title`
    attribute is set directly in the view, it will override any value here.

    * `label_link` - the label of a user interface element may optionally define
    a URL to link to when clicking the label, such as a link to relevant
    documentation.  When this value is not `nil`, the link is the URL to the
    resource to access; when `nil` the label is rendered without a link.
    (*Note that `label_link` is not yet implemented in most components.*)

    * `info` - in some situations, abbreviated additional information for a
    user interface element is made available to the user, for example via the
    `MscmpSystForms.WebComponent.msinfo/1` web component.  This attribute
    configures the text that is displayed to the user in these scenarios.  If
    the value is `nil` then no text is displayed even if it could be.

    * `button_state` - if the component being configured by this value is a
    `MscmpSystForms.WebComponents.msvalidated_button/1` component, the
    `button_state` value will indicate the current display state of the button.
    See `t:MscmpSystForms.Types.msvalidated_button_states/0` for the available
    states.

    * `overrides` - a list of currently active processing overrides. A process
    override is a state which can be set for the form which simply indicates
    that some possibly long running application operation has been started, but
    is not yet finished.  See `MscmpSystForms.start_processing_override/2` for
    more about processing overrides.  The form and its components can respond to
    an active processing override by, for example, changing their display and
    interactivity characteristics until the processing override condition ends.
    If there are no processing overrides active, this value will be an empty
    list.

    * `modes` - the currently computed display modes for the component.  The
    display modes are computed by assessing the prevailing runtime form state
    and user permissions to determine the behavior of the component at render
    time.  These modes are then used by the component when creating the view
    to render.

  See `MscmpSystForms.Types.ComponentConfig` for more.
  """
  @type t() :: %__MODULE__{
          form_id: Types.form_id(),
          binding_id: Types.binding_id() | nil,
          permission: Types.permission_name() | nil,
          label: String.t() | nil,
          label_link: String.t() | nil,
          info: String.t() | nil,
          button_state: Types.msvalidated_button_states() | nil,
          overrides: list(atom()) | nil,
          modes: map()
        }
end
