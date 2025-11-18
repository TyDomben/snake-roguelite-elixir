defmodule SnakeRoguelite.GameServer do
  @moduledoc """
  GenServer that manages the state and logic for a Snake game session.

  This demonstrates key Elixir/OTP patterns:
  - GenServer for stateful processes
  - Pattern matching for game logic
  - Immutable data structures
  - Process-based architecture
  """

  use GenServer
  require Logger

  alias SnakeRoguelite.HighScoreManager

  # Client API

  @doc """
  Starts a new game server for a given player session.
  """
  def start_link(session_id) do
    GenServer.start_link(__MODULE__, session_id, name: via_tuple(session_id))
  end

  @doc """
  Gets the current game state.
  """
  def get_state(session_id) do
    GenServer.call(via_tuple(session_id), :get_state)
  end

  @doc """
  Changes the snake's direction.
  """
  def change_direction(session_id, direction) do
    GenServer.cast(via_tuple(session_id), {:change_direction, direction})
  end

  @doc """
  Advances the game by one tick (moves snake forward).
  """
  def tick(session_id) do
    GenServer.cast(via_tuple(session_id), :tick)
  end

  @doc """
  Selects an upgrade when leveling up.
  """
  def select_upgrade(session_id, upgrade_id) do
    GenServer.cast(via_tuple(session_id), {:select_upgrade, upgrade_id})
  end

  @doc """
  Restarts the game.
  """
  def restart(session_id) do
    GenServer.cast(via_tuple(session_id), :restart)
  end

  # Server Callbacks

  @impl true
  def init(session_id) do
    Logger.info("Starting game server for session: #{session_id}")
    {:ok, initial_state()}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:change_direction, new_direction}, state) do
    # Prevent the snake from reversing into itself
    valid_direction = case {state.direction, new_direction} do
      {:up, :down} -> false
      {:down, :up} -> false
      {:left, :right} -> false
      {:right, :left} -> false
      _ -> true
    end

    new_state = if valid_direction and state.status == :playing do
      %{state | next_direction: new_direction}
    else
      state
    end

    {:noreply, new_state}
  end

  @impl true
  def handle_cast(:tick, %{status: :playing} = state) do
    # Update direction if there's a queued direction change
    state = %{state | direction: state.next_direction}

    # Calculate new head position based on current direction
    new_head = move_head(state.snake.head, state.direction)

    # Check for collisions
    cond do
      # Wall collision
      collision_with_wall?(new_head, state.grid_size) ->
        {:noreply, handle_collision(state)}

      # Self collision (only if ghost mode is not active)
      !has_upgrade?(state, :ghost_mode) and collision_with_self?(new_head, state.snake.body) ->
        {:noreply, handle_collision(state)}

      # Food collision
      new_head == state.food ->
        {:noreply, handle_food_eaten(state, new_head)}

      # Normal movement
      true ->
        {:noreply, move_snake(state, new_head)}
    end
  end

  @impl true
  def handle_cast(:tick, state) do
    # If game is not playing (game over or level up), don't process tick
    {:noreply, state}
  end

  @impl true
  def handle_cast({:select_upgrade, upgrade_id}, %{status: :level_up} = state) do
    # Find the selected upgrade
    selected_upgrade = Enum.find(state.available_upgrades, &(&1.id == upgrade_id))

    if selected_upgrade do
      # Add upgrade to active upgrades
      new_upgrades = [selected_upgrade | state.upgrades]

      # Apply immediate effects of the upgrade
      new_state = apply_upgrade_effects(%{state | upgrades: new_upgrades}, selected_upgrade)

      # Resume game
      new_state = %{new_state |
        status: :playing,
        available_upgrades: []
      }

      {:noreply, new_state}
    else
      {:noreply, state}
    end
  end

  @impl true
  def handle_cast({:select_upgrade, _}, state) do
    # Ignore upgrade selection if not in level_up state
    {:noreply, state}
  end

  @impl true
  def handle_cast(:restart, _state) do
    {:noreply, initial_state()}
  end

  # Private Functions

  defp via_tuple(session_id) do
    {:via, Registry, {SnakeRoguelite.GameRegistry, session_id}}
  end

  defp initial_state do
    grid_size = 20

    # Start snake in the middle of the grid
    initial_head = {div(grid_size, 2), div(grid_size, 2)}
    initial_body = [
      {div(grid_size, 2), div(grid_size, 2) + 1},
      {div(grid_size, 2), div(grid_size, 2) + 2}
    ]

    # Get the persistent high score
    high_score = HighScoreManager.get_high_score()

    %{
      # Grid configuration
      grid_size: grid_size,

      # Snake state
      snake: %{
        head: initial_head,
        body: initial_body
      },
      direction: :up,
      next_direction: :up,

      # Food position
      food: spawn_food(grid_size, initial_head, initial_body),

      # Game state
      status: :playing,  # :playing, :game_over, :level_up
      score: 0,
      level: 1,
      food_eaten: 0,
      high_score: high_score,

      # Lives system
      lives: 1,

      # Roguelite mechanics
      upgrades: [],
      available_upgrades: [],

      # Speed control (milliseconds per tick)
      base_speed: 200,
      speed_modifier: 1.0
    }
  end

  defp move_head({x, y}, :up), do: {x, y - 1}
  defp move_head({x, y}, :down), do: {x, y + 1}
  defp move_head({x, y}, :left), do: {x - 1, y}
  defp move_head({x, y}, :right), do: {x + 1, y}

  defp collision_with_wall?({x, y}, grid_size) do
    x < 0 or x >= grid_size or y < 0 or y >= grid_size
  end

  defp collision_with_self?(head, body) do
    Enum.member?(body, head)
  end

  defp move_snake(state, new_head) do
    # Move snake forward: new head, drop last tail segment
    new_body = [state.snake.head | Enum.drop(state.snake.body, -1)]

    %{state |
      snake: %{
        head: new_head,
        body: new_body
      }
    }
  end

  defp handle_food_eaten(state, new_head) do
    # Increase score (with multiplier if applicable)
    score_gain = if has_upgrade?(state, :double_points), do: 20, else: 10
    new_score = state.score + score_gain
    new_food_eaten = state.food_eaten + 1

    # Grow snake: new head, keep all body segments
    new_body = [state.snake.head | state.snake.body]

    # Update high score (persists across restarts)
    new_high_score = HighScoreManager.update_high_score(new_score)

    # Check for level up (every 5 food)
    if rem(new_food_eaten, 5) == 0 do
      # Level up! Pause game and offer upgrades
      %{state |
        snake: %{head: new_head, body: new_body},
        food: spawn_food(state.grid_size, new_head, new_body, state.upgrades),
        score: new_score,
        food_eaten: new_food_eaten,
        level: state.level + 1,
        high_score: new_high_score,
        status: :level_up,
        available_upgrades: generate_upgrades()
      }
    else
      # Normal food consumption
      %{state |
        snake: %{head: new_head, body: new_body},
        food: spawn_food(state.grid_size, new_head, new_body, state.upgrades),
        score: new_score,
        food_eaten: new_food_eaten,
        high_score: new_high_score
      }
    end
  end

  defp handle_collision(state) do
    if state.lives > 1 do
      # Use an extra life
      %{state | lives: state.lives - 1}
    else
      # Game over
      %{state | status: :game_over}
    end
  end

  defp spawn_food(grid_size, head, body, upgrades \\ []) do
    # Generate a random position that's not occupied by the snake
    occupied = [head | body]

    all_positions = for x <- 0..(grid_size - 1),
                        y <- 0..(grid_size - 1),
                        do: {x, y}

    available_positions = all_positions -- occupied

    if length(available_positions) > 0 do
      # If food magnet is active, spawn food closer to the snake
      if has_upgrade_by_id?(upgrades, :food_magnet) do
        spawn_food_nearby(head, available_positions, grid_size)
      else
        Enum.random(available_positions)
      end
    else
      # Fallback if somehow the grid is full
      {0, 0}
    end
  end

  defp spawn_food_nearby(head, available_positions, grid_size) do
    # Calculate distance from head for all available positions
    {head_x, head_y} = head
    max_distance = div(grid_size, 3)  # Food spawns within 1/3 of grid from snake

    # Find positions within the magnetic range
    nearby_positions = Enum.filter(available_positions, fn {x, y} ->
      distance = abs(x - head_x) + abs(y - head_y)  # Manhattan distance
      distance <= max_distance
    end)

    # If there are nearby positions, pick one; otherwise pick any available
    if length(nearby_positions) > 0 do
      Enum.random(nearby_positions)
    else
      Enum.random(available_positions)
    end
  end

  defp has_upgrade_by_id?(upgrades, upgrade_id) do
    Enum.any?(upgrades, &(&1.id == upgrade_id))
  end

  defp generate_upgrades do
    # All possible upgrades
    all_upgrades = [
      %{
        id: :speed_boost,
        name: "Speed Demon",
        description: "Move 20% faster",
        type: :speed,
        value: 0.8
      },
      %{
        id: :speed_reduction,
        name: "Slow and Steady",
        description: "Move 30% slower for better control",
        type: :speed,
        value: 1.3
      },
      %{
        id: :ghost_mode,
        name: "Ghost Mode",
        description: "Phase through yourself",
        type: :ability,
        value: true
      },
      %{
        id: :extra_life,
        name: "Extra Life",
        description: "Gain one extra life",
        type: :life,
        value: 1
      },
      %{
        id: :double_points,
        name: "Double Points",
        description: "Earn 2x points from food",
        type: :multiplier,
        value: 2
      },
      %{
        id: :food_magnet,
        name: "Food Magnet",
        description: "Food spawns closer to you",
        type: :ability,
        value: true
      },
      %{
        id: :shrink,
        name: "Diet Plan",
        description: "Shrink by 3 segments (if possible)",
        type: :size,
        value: -3
      }
    ]

    # Return 3 random unique upgrades
    Enum.take_random(all_upgrades, 3)
  end

  defp apply_upgrade_effects(state, upgrade) do
    case upgrade.type do
      :speed ->
        %{state | speed_modifier: state.speed_modifier * upgrade.value}

      :life ->
        %{state | lives: state.lives + upgrade.value}

      :size ->
        # Shrink the snake if possible
        shrink_amount = abs(upgrade.value)
        current_length = length(state.snake.body)

        if current_length > shrink_amount do
          new_body = Enum.drop(state.snake.body, -shrink_amount)
          put_in(state.snake.body, new_body)
        else
          state
        end

      _ ->
        # Other upgrades are passive (checked with has_upgrade?)
        state
    end
  end

  defp has_upgrade?(state, upgrade_id) do
    Enum.any?(state.upgrades, &(&1.id == upgrade_id))
  end
end
