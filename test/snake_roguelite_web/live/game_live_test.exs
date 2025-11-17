defmodule SnakeRogueliteWeb.GameLiveTest do
  use SnakeRogueliteWeb.ConnCase
  import Phoenix.LiveViewTest

  test "disconnected and connected mount", %{conn: conn} do
    {:ok, view, html} = live(conn, "/")

    assert html =~ "Snake Roguelite"
    assert has_element?(view, "div", "Score")
  end

  test "displays game board", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    # Should have game cells
    assert has_element?(view, ".game-cell")
  end
end
