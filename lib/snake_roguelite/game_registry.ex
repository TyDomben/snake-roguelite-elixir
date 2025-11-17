defmodule SnakeRoguelite.GameRegistry do
  @moduledoc """
  Registry for tracking active game sessions.

  Each LiveView session gets its own GameServer process,
  identified by a unique session ID.
  """

  def child_spec(_) do
    Registry.child_spec(
      keys: :unique,
      name: __MODULE__
    )
  end
end
