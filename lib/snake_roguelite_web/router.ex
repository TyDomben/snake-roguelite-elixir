defmodule SnakeRogueliteWeb.Router do
  use SnakeRogueliteWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {SnakeRogueliteWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", SnakeRogueliteWeb do
    pipe_through :browser

    # Main game page
    live "/", GameLive
  end
end
