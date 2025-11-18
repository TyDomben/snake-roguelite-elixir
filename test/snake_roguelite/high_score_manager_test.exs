defmodule SnakeRoguelite.HighScoreManagerTest do
  use ExUnit.Case, async: false  # Not async because we're testing ETS table

  alias SnakeRoguelite.HighScoreManager

  setup do
    # Clear any existing high scores
    # The manager should already be started by the application
    :ok
  end

  describe "high score persistence" do
    test "returns 0 for new players" do
      player_id = "new_player_#{:rand.uniform(10000)}"
      score = HighScoreManager.get_high_score(player_id)
      assert score == 0
    end

    test "updates high score for new record" do
      player_id = "test_player_#{:rand.uniform(10000)}"

      # Set initial score
      high_score = HighScoreManager.update_high_score(100, player_id)
      assert high_score == 100

      # Verify it persists
      assert HighScoreManager.get_high_score(player_id) == 100
    end

    test "keeps higher score when lower score is submitted" do
      player_id = "test_player_#{:rand.uniform(10000)}"

      # Set high score
      HighScoreManager.update_high_score(200, player_id)

      # Try to update with lower score
      high_score = HighScoreManager.update_high_score(100, player_id)

      # Should still be 200
      assert high_score == 200
      assert HighScoreManager.get_high_score(player_id) == 200
    end

    test "updates to new high score when score is higher" do
      player_id = "test_player_#{:rand.uniform(10000)}"

      # Set initial score
      HighScoreManager.update_high_score(100, player_id)

      # Update with higher score
      high_score = HighScoreManager.update_high_score(300, player_id)

      assert high_score == 300
      assert HighScoreManager.get_high_score(player_id) == 300
    end

    test "uses :global as default player_id" do
      # This tests that the default global high score works
      initial_score = HighScoreManager.get_high_score()
      assert is_integer(initial_score)
      assert initial_score >= 0
    end

    test "supports multiple players independently" do
      player1 = "player1_#{:rand.uniform(10000)}"
      player2 = "player2_#{:rand.uniform(10000)}"

      HighScoreManager.update_high_score(150, player1)
      HighScoreManager.update_high_score(250, player2)

      assert HighScoreManager.get_high_score(player1) == 150
      assert HighScoreManager.get_high_score(player2) == 250
    end
  end
end
