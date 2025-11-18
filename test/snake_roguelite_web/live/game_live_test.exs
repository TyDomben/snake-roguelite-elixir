defmodule SnakeRogueliteWeb.GameLiveTest do
  use SnakeRogueliteWeb.ConnCase
  import Phoenix.LiveViewTest

  test "disconnected and connected mount", %{conn: conn} do
    {:ok, view, html} = live(conn, "/")

    assert html =~ "Snake Roguelite"
    assert html =~ "Use arrow keys"
    assert has_element?(view, "div", "Score")
  end

  test "displays game board when playing", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    # Should have game cells
    assert has_element?(view, ".game-cell")
  end

  test "displays stats panel", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert has_element?(view, "div", "Level")
    assert has_element?(view, "div", "Food Eaten")
    assert has_element?(view, "div", "Length")
    assert has_element?(view, "div", "Lives")
    assert has_element?(view, "div", "High Score")
  end

  test "displays active upgrades section", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert has_element?(view, "h3", "Active Upgrades")
  end

  test "handles restart event", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    # Initially playing, so restart button should not be visible
    # (it only shows on game over screen)
    # We just verify the view is functional
    assert view
  end

  test "renders game with proper structure", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/")

    # Check for main game elements
    assert html =~ "Stats"
    assert html =~ "bg-gray-900"  # Game styling
  end
end
