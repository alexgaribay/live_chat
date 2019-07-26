defmodule LiveChatWeb.ComponentView do
  use LiveChatWeb, :view

  import LiveChatWeb.ErrorHelpers, only: [field_errors: 2]

  @doc """
  A text field for a form that that automatically renders field errors.
  """
  def simple_text_field(form, field_name, opts \\ []) do
    errors = field_errors(form, field_name)
    render("simple_text_field.html", form: form, name: field_name, errors: errors, opts: opts)
  end
end
