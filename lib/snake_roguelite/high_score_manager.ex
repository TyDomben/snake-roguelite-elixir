defmodule SnakeRoguelite.HighScoreManager do
  @moduledoc """
  Simple ETS-based high score manager to persist high scores across game sessions.

  This demonstrates:
  - ETS (Erlang Term Storage) for fast in-memory data
  - Process-based state management
  - Supervision for fault tolerance
  """

  use GenServer
  require Logger

  @table_name :high_scores

  # Client API

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Gets the high score for a given player (session).
  Returns 0 if no high score exists.
  """
  def get_high_score(player_id \\ :global) do
    case :ets.lookup(@table_name, player_id) do
      [{^player_id, score}] -> score
      [] -> 0
    end
  end

  @doc """
  Updates the high score if the new score is higher.
  Returns the current high score.
  """
  def update_high_score(score, player_id \\ :global) do
    GenServer.call(__MODULE__, {:update_high_score, player_id, score})
  end

  # Server Callbacks

  @impl true
  def init(:ok) do
    # Create ETS table for storing high scores
    # :set = key-value store
    # :named_table = can reference by name
    # :public = any process can read/write
    :ets.new(@table_name, [:set, :named_table, :public])

    Logger.info("High Score Manager started")
    {:ok, %{}}
  end

  @impl true
  def handle_call({:update_high_score, player_id, new_score}, _from, state) do
    current_high_score = get_high_score(player_id)

    final_high_score = if new_score > current_high_score do
      :ets.insert(@table_name, {player_id, new_score})
      new_score
    else
      current_high_score
    end

    {:reply, final_high_score, state}
  end
end
