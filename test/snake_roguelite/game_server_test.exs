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
      assert is_tuple(state.food)
      assert state.base_speed == 200
      assert state.speed_modifier == 1.0
    end

    test "snake starts in the middle of the grid", %{session_id: session_id} do
      state = GameServer.get_state(session_id)

      {x, y} = state.snake.head
      assert x == 10
      assert y == 10
    end

    test "food spawns in a valid position", %{session_id: session_id} do
      state = GameServer.get_state(session_id)

      {food_x, food_y} = state.food
      assert food_x >= 0 and food_x < state.grid_size
      assert food_y >= 0 and food_y < state.grid_size

      # Food should not be on the snake
      assert state.food != state.snake.head
      refute state.food in state.snake.body
    end

    test "loads high score from persistence", %{session_id: session_id} do
      state = GameServer.get_state(session_id)
      # High score should be loaded (may be 0 initially)
      assert is_integer(state.high_score)
      assert state.high_score >= 0
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

    test "allows changing to perpendicular directions", %{session_id: session_id} do
      initial_state = GameServer.get_state(session_id)
      assert initial_state.direction == :up

      # Can turn left from up
      GameServer.change_direction(session_id, :left)
      state = GameServer.get_state(session_id)
      assert state.next_direction == :left

      # Can turn right from up
      GameServer.change_direction(session_id, :right)
      state = GameServer.get_state(session_id)
      assert state.next_direction == :right
    end

    test "snake moves forward each tick", %{session_id: session_id} do
      initial_state = GameServer.get_state(session_id)
      initial_head = initial_state.snake.head

      # Move the snake
      GameServer.tick(session_id)

      new_state = GameServer.get_state(session_id)
      new_head = new_state.snake.head

      # Head should have moved up (initial direction)
      {init_x, init_y} = initial_head
      {new_x, new_y} = new_head

      assert new_x == init_x
      assert new_y == init_y - 1  # Moved up
    end
  end

  describe "collision detection" do
    test "detects when snake is in safe position", %{session_id: session_id} do
      state = GameServer.get_state(session_id)

      # Head should be in middle, not near wall
      {x, y} = state.snake.head
      assert x > 0 and x < state.grid_size - 1
      assert y > 0 and y < state.grid_size - 1
    end
  end

  describe "scoring" do
    test "score starts at zero", %{session_id: session_id} do
      state = GameServer.get_state(session_id)
      assert state.score == 0
    end

    test "food_eaten counter starts at zero", %{session_id: session_id} do
      state = GameServer.get_state(session_id)
      assert state.food_eaten == 0
    end
  end

  describe "level system" do
    test "starts at level 1", %{session_id: session_id} do
      state = GameServer.get_state(session_id)
      assert state.level == 1
    end

    test "has no available upgrades initially", %{session_id: session_id} do
      state = GameServer.get_state(session_id)
      assert state.available_upgrades == []
    end

    test "has no active upgrades initially", %{session_id: session_id} do
      state = GameServer.get_state(session_id)
      assert state.upgrades == []
    end
  end

  describe "restart" do
    test "resets game to initial state but preserves high score", %{session_id: session_id} do
      # Make some changes to the game
      GameServer.change_direction(session_id, :left)
      GameServer.tick(session_id)

      # Restart the game
      GameServer.restart(session_id)

      # Get new state
      new_state = GameServer.get_state(session_id)

      # Should be reset
      assert new_state.score == 0
      assert new_state.level == 1
      assert new_state.food_eaten == 0
      assert new_state.direction == :up
      assert new_state.status == :playing

      # High score should be preserved (loaded from ETS)
      assert is_integer(new_state.high_score)
    end
  end

  describe "upgrades" do
    test "upgrade structure exists in state", %{session_id: session_id} do
      state = GameServer.get_state(session_id)
      assert is_list(state.upgrades)
      assert is_list(state.available_upgrades)
    end
  end
end
