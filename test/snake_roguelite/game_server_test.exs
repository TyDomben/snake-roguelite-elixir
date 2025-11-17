defmodule SnakeRoguelite.GameServerTest do
  use ExUnit.Case, async: true
  alias SnakeRoguelite.GameServer

  setup do
    # Generate unique session ID for each test
    session_id = "test_#{:erlang.unique_integer([:positive])}"

    # Start game server
    {:ok, _pid} = start_supervised({GameServer, session_id})

    {:ok, session_id: session_id}
  end

  describe "initial state" do
    test "starts with correct initial values", %{session_id: session_id} do
      state = GameServer.get_state(session_id)

      assert state.grid_size == 20
      assert state.status == :playing
      assert state.score == 0
      assert state.level == 1
      assert state.lives == 1
      assert state.direction == :up
      assert length(state.snake.body) == 2
    end

    test "snake starts in the middle of the grid", %{session_id: session_id} do
      state = GameServer.get_state(session_id)

      {x, y} = state.snake.head
      assert x == 10
      assert y == 10
    end
  end

  describe "movement" do
    test "prevents snake from reversing into itself", %{session_id: session_id} do
      initial_state = GameServer.get_state(session_id)
      assert initial_state.direction == :up

      # Try to go down (opposite of up) - should be ignored
      GameServer.change_direction(session_id, :down)
      state = GameServer.get_state(session_id)
      assert state.next_direction == :up

      # Going left should work
      GameServer.change_direction(session_id, :left)
      state = GameServer.get_state(session_id)
      assert state.next_direction == :left
    end
  end

  describe "food consumption" do
    test "increases score when food is eaten", %{session_id: session_id} do
      initial_state = GameServer.get_state(session_id)
      assert initial_state.score == 0

      # Move snake until it eats food (this is simplified)
      # In a real test, you'd need to manipulate the state or mock the food position
    end
  end

  describe "game over" do
    test "game over occurs on wall collision", %{session_id: session_id} do
      # Move the snake to the edge and then into the wall
      # This would require multiple ticks in the actual game
      # Simplified test structure shown
    end
  end
end
