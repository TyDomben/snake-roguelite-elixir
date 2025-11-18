defmodule SnakeRogueliteWeb.ErrorHTML do
  use SnakeRogueliteWeb, :html

  # Custom error pages for better user experience
  embed_templates "error_html/*"

  # Fallback for any other error codes
  def render(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
