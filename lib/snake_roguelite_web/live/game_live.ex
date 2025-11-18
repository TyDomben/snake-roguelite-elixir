defmodule SnakeRogueliteWeb.GameLive do
  @moduledoc """
  LiveView for the Snake Roguelite game.

  Demonstrates Phoenix LiveView patterns:
  - Real-time updates without JavaScript
  - Event handling (keyboard input)
  - Process messaging with GenServer
  - Scheduled tasks (game tick)
  """

  use SnakeRogueliteWeb, :live_view
  alias SnakeRoguelite.GameServer

  # Lifecycle Callbacks

  @impl true
  def mount(_params, _session, socket) do
    # Generate unique session ID for this LiveView connection
    session_id = generate_session_id()

    # Start a game server for this session
    {:ok, pid} = DynamicSupervisor.start_child(
      SnakeRoguelite.GameSupervisor,
      {GameServer, session_id}
    )

    # Get initial game state
    game_state = GameServer.get_state(session_id)

    # Start game loop if playing
    if connected?(socket) and game_state.status == :playing do
      schedule_tick(game_state)
    end

    socket = socket
    |> assign(:session_id, session_id)
    |> assign(:game_server_pid, pid)
    |> assign(:game_state, game_state)

    {:ok, socket}
  end

  @impl true
  def terminate(_reason, socket) do
    # Clean up the game server when the LiveView session ends
    # This prevents orphaned game processes
    if socket.assigns[:game_server_pid] do
      DynamicSupervisor.terminate_child(
        SnakeRoguelite.GameSupervisor,
        socket.assigns.game_server_pid
      )
    end

    :ok
  end

  @impl true
  def handle_event("keydown", %{"key" => key}, socket) do
    # Map arrow keys to directions
    direction = case key do
      "ArrowUp" -> :up
      "ArrowDown" -> :down
      "ArrowLeft" -> :left
      "ArrowRight" -> :right
      _ -> nil
    end

    # Send direction change to game server
    if direction do
      GameServer.change_direction(socket.assigns.session_id, direction)
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("select_upgrade", %{"upgrade-id" => upgrade_id}, socket) do
    # Safely convert string ID to atom
    # Using try/catch to handle invalid upgrade IDs gracefully
    upgrade_atom = try do
      String.to_existing_atom(upgrade_id)
    rescue
      ArgumentError ->
        # If atom doesn't exist, log error and return nil
        require Logger
        Logger.warning("Invalid upgrade ID attempted: #{upgrade_id}")
        nil
    end

    # Select the upgrade if valid
    if upgrade_atom do
      GameServer.select_upgrade(socket.assigns.session_id, upgrade_atom)
    end

    # Get updated state
    game_state = GameServer.get_state(socket.assigns.session_id)

    # Resume game loop
    if game_state.status == :playing do
      schedule_tick(game_state)
    end

    {:noreply, assign(socket, :game_state, game_state)}
  end

  @impl true
  def handle_event("restart", _params, socket) do
    # Restart the game
    GameServer.restart(socket.assigns.session_id)

    # Get fresh state
    game_state = GameServer.get_state(socket.assigns.session_id)

    # Start game loop
    schedule_tick(game_state)

    {:noreply, assign(socket, :game_state, game_state)}
  end

  @impl true
  def handle_info(:tick, socket) do
    # Advance game by one tick
    GameServer.tick(socket.assigns.session_id)

    # Get updated state
    game_state = GameServer.get_state(socket.assigns.session_id)

    # Schedule next tick if still playing
    if game_state.status == :playing do
      schedule_tick(game_state)
    end

    {:noreply, assign(socket, :game_state, game_state)}
  end

  # Template Rendering

  @impl true
  def render(assigns) do
    ~H"""
    <div class="h-full flex items-center justify-center bg-gray-900" phx-window-keydown="keydown">
      <div class="max-w-6xl w-full p-4">
        <!-- Game Header -->
        <div class="text-center mb-4">
          <h1 class="text-4xl font-bold text-green-400 mb-2">🐍 Snake Roguelite</h1>
          <p class="text-gray-400">Use arrow keys to control the snake</p>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-3 gap-4">
          <!-- Left Panel: Stats -->
          <div class="bg-gray-800 rounded-lg p-4">
            <h2 class="text-xl font-bold text-green-400 mb-4">Stats</h2>

            <div class="space-y-3">
              <div class="bg-gray-900 rounded p-3">
                <div class="text-gray-400 text-sm">Score</div>
                <div class="text-2xl font-bold text-white"><%= @game_state.score %></div>
              </div>

              <div class="bg-gray-900 rounded p-3">
                <div class="text-gray-400 text-sm">Level</div>
                <div class="text-2xl font-bold text-blue-400"><%= @game_state.level %></div>
              </div>

              <div class="bg-gray-900 rounded p-3">
                <div class="text-gray-400 text-sm">Food Eaten</div>
                <div class="text-2xl font-bold text-yellow-400"><%= @game_state.food_eaten %></div>
              </div>

              <div class="bg-gray-900 rounded p-3">
                <div class="text-gray-400 text-sm">Length</div>
                <div class="text-2xl font-bold text-purple-400"><%= length(@game_state.snake.body) + 1 %></div>
              </div>

              <div class="bg-gray-900 rounded p-3">
                <div class="text-gray-400 text-sm">Lives</div>
                <div class="text-2xl font-bold text-red-400">
                  <%= String.duplicate("❤️", @game_state.lives) %>
                </div>
              </div>

              <div class="bg-gray-900 rounded p-3">
                <div class="text-gray-400 text-sm">High Score</div>
                <div class="text-xl font-bold text-yellow-300"><%= @game_state.high_score %></div>
              </div>
            </div>

            <!-- Active Upgrades -->
            <div class="mt-6">
              <h3 class="text-lg font-bold text-green-400 mb-2">Active Upgrades</h3>
              <div class="space-y-2">
                <%= if length(@game_state.upgrades) > 0 do %>
                  <%= for upgrade <- @game_state.upgrades do %>
                    <div class="active-upgrade">
                      <%= upgrade.name %>
                    </div>
                  <% end %>
                <% else %>
                  <div class="text-gray-500 text-sm">No upgrades yet</div>
                <% end %>
              </div>
            </div>
          </div>

          <!-- Center: Game Board -->
          <div class="lg:col-span-2">
            <%= if @game_state.status == :playing do %>
              <.game_board game_state={@game_state} />
            <% end %>

            <%= if @game_state.status == :level_up do %>
              <.upgrade_selection game_state={@game_state} />
            <% end %>

            <%= if @game_state.status == :game_over do %>
              <.game_over game_state={@game_state} />
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # Component: Game Board

  defp game_board(assigns) do
    ~H"""
    <div class="bg-gray-800 rounded-lg p-4">
      <div class="inline-grid gap-0" style={"grid-template-columns: repeat(#{@game_state.grid_size}, minmax(0, 1fr));"}>
        <%= for y <- 0..(@game_state.grid_size - 1) do %>
          <%= for x <- 0..(@game_state.grid_size - 1) do %>
            <div class={"game-cell w-6 h-6 #{cell_class({x, y}, @game_state)}"}>
            </div>
          <% end %>
        <% end %>
      </div>

      <div class="mt-4 text-center text-gray-400 text-sm">
        Next food in <%= 5 - rem(@game_state.food_eaten, 5) %> to level up!
      </div>
    </div>
    """
  end

  # Component: Upgrade Selection

  defp upgrade_selection(assigns) do
    ~H"""
    <div class="bg-gray-800 rounded-lg p-6">
      <div class="text-center mb-6">
        <h2 class="text-3xl font-bold text-yellow-400 mb-2">🎉 LEVEL UP!</h2>
        <p class="text-xl text-green-400">Level <%= @game_state.level %> Reached!</p>
        <p class="text-gray-400 mt-2">Choose one upgrade to continue:</p>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <%= for upgrade <- @game_state.available_upgrades do %>
          <div
            class="upgrade-card"
            phx-click="select_upgrade"
            phx-value-upgrade-id={upgrade.id}
          >
            <h3 class="text-lg font-bold text-green-400 mb-2"><%= upgrade.name %></h3>
            <p class="text-gray-300 text-sm"><%= upgrade.description %></p>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  # Component: Game Over Screen

  defp game_over(assigns) do
    ~H"""
    <div class="bg-gray-800 rounded-lg p-8 text-center">
      <h2 class="text-4xl font-bold text-red-400 mb-4">💀 GAME OVER</h2>

      <div class="space-y-4 mb-8">
        <div>
          <div class="text-gray-400">Final Score</div>
          <div class="text-5xl font-bold text-white"><%= @game_state.score %></div>
        </div>

        <div>
          <div class="text-gray-400">Level Reached</div>
          <div class="text-3xl font-bold text-blue-400"><%= @game_state.level %></div>
        </div>

        <div>
          <div class="text-gray-400">Food Eaten</div>
          <div class="text-2xl font-bold text-yellow-400"><%= @game_state.food_eaten %></div>
        </div>

        <%= if @game_state.score == @game_state.high_score and @game_state.score > 0 do %>
          <div class="text-yellow-300 font-bold text-xl animate-pulse">
            🏆 NEW HIGH SCORE! 🏆
          </div>
        <% end %>
      </div>

      <button
        phx-click="restart"
        class="bg-green-600 hover:bg-green-700 text-white font-bold py-3 px-8 rounded-lg text-xl transition-all"
      >
        Play Again
      </button>
    </div>
    """
  end

  # Helper Functions

  defp cell_class(pos, game_state) do
    cond do
      pos == game_state.snake.head -> "snake-head"
      pos in game_state.snake.body -> "snake-body"
      pos == game_state.food -> "food"
      true -> "bg-gray-900"
    end
  end

  defp schedule_tick(game_state) do
    # Calculate tick interval based on speed modifiers
    tick_interval = round(game_state.base_speed * game_state.speed_modifier)
    Process.send_after(self(), :tick, tick_interval)
  end

  defp generate_session_id do
    :crypto.strong_rand_bytes(16) |> Base.encode16()
  end
end
