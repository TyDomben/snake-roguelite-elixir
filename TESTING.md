# Testing Guide

This document explains how to run and understand the tests for the Snake Roguelite project.

## Running Tests

### Run All Tests

```bash
mix test
```

### Run Specific Test File

```bash
# Test the GameServer
mix test test/snake_roguelite/game_server_test.exs

# Test the HighScoreManager
mix test test/snake_roguelite/high_score_manager_test.exs

# Test the LiveView
mix test test/snake_roguelite_web/live/game_live_test.exs
```

### Run Tests with Coverage

```bash
mix test --cover
```

### Run Tests in Watch Mode

```bash
mix test.watch
```

## Test Structure

### GameServer Tests

Located in `test/snake_roguelite/game_server_test.exs`

**What's Tested:**
- ✅ Initial state configuration
- ✅ Snake starting position
- ✅ Food spawning logic
- ✅ High score loading from persistence
- ✅ Movement mechanics
- ✅ Direction change validation (preventing reverse)
- ✅ Perpendicular direction changes
- ✅ Snake movement per tick
- ✅ Collision detection setup
- ✅ Scoring system
- ✅ Level progression
- ✅ Upgrade system structure
- ✅ Game restart functionality

**Key Patterns Demonstrated:**
```elixir
# Setup with unique session IDs
setup do
  session_id = "test_#{:erlang.unique_integer([:positive])}"
  {:ok, _pid} = start_supervised({GameServer, session_id})
  {:ok, session_id: session_id}
end

# Testing state
test "starts with correct initial values", %{session_id: session_id} do
  state = GameServer.get_state(session_id)
  assert state.grid_size == 20
  assert state.status == :playing
end

# Testing behavior
test "prevents snake from reversing into itself", %{session_id: session_id} do
  GameServer.change_direction(session_id, :down)
  state = GameServer.get_state(session_id)
  assert state.next_direction == :up  # Unchanged
end
```

### HighScoreManager Tests

Located in `test/snake_roguelite/high_score_manager_test.exs`

**What's Tested:**
- ✅ New player default score (0)
- ✅ Updating high scores
- ✅ Keeping higher score when lower submitted
- ✅ Updating to new high score
- ✅ Global default player ID
- ✅ Multiple independent players

**Why async: false:**
```elixir
use ExUnit.Case, async: false  # ETS table is shared
```

### LiveView Tests

Located in `test/snake_roguelite_web/live/game_live_test.exs`

**What's Tested:**
- ✅ Mount and connection
- ✅ HTML rendering
- ✅ Game board display
- ✅ Stats panel elements
- ✅ Active upgrades section
- ✅ Proper structure and styling

**LiveView Testing Pattern:**
```elixir
test "disconnected and connected mount", %{conn: conn} do
  {:ok, view, html} = live(conn, "/")
  assert html =~ "Snake Roguelite"
  assert has_element?(view, "div", "Score")
end
```

## Writing New Tests

### Testing GenServer Functions

```elixir
test "your test name", %{session_id: session_id} do
  # Get initial state
  initial_state = GameServer.get_state(session_id)

  # Perform action
  GameServer.your_function(session_id, args)

  # Verify result
  new_state = GameServer.get_state(session_id)
  assert new_state.something == expected_value
end
```

### Testing LiveView Events

```elixir
test "handles event", %{conn: conn} do
  {:ok, view, _html} = live(conn, "/")

  # Trigger event
  render_click(view, "event_name", %{"param" => "value"})

  # Verify result
  assert has_element?(view, "selector", "expected text")
end
```

### Testing ETS/State Persistence

```elixir
test "persists across calls" do
  player_id = "test_#{:rand.uniform(10000)}"

  # Set value
  HighScoreManager.update_high_score(100, player_id)

  # Verify persistence
  assert HighScoreManager.get_high_score(player_id) == 100
end
```

## Test Coverage Goals

Current coverage areas:

- ✅ **Game Logic**: Movement, collision, scoring
- ✅ **State Management**: GenServer operations, state transitions
- ✅ **Persistence**: High score ETS storage
- ✅ **LiveView**: Rendering, events, lifecycle
- ✅ **Error Handling**: Invalid inputs, edge cases

## Continuous Integration

To set up CI (GitHub Actions example):

```yaml
# .github/workflows/test.yml
name: Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest

    services:
      postgres:
        image: postgres:14
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
      - uses: actions/checkout@v3
      - uses: erlef/setup-beam@v1
        with:
          otp-version: '25.0'
          elixir-version: '1.14.0'
      - run: mix deps.get
      - run: mix test
```

## Debugging Tests

### Print State for Debugging

```elixir
test "debug test", %{session_id: session_id} do
  state = GameServer.get_state(session_id)
  IO.inspect(state, label: "Current State")
  # ... assertions
end
```

### Run Single Test

```bash
mix test test/snake_roguelite/game_server_test.exs:16
```

Where `:16` is the line number of the test.

### Verbose Output

```bash
mix test --trace
```

## Best Practices

1. **Use Descriptive Names**: Test names should explain what's being tested
2. **Arrange-Act-Assert**: Structure tests in three clear phases
3. **One Concept Per Test**: Each test should verify one behavior
4. **Use Setup Wisely**: Share common setup, but keep tests independent
5. **Test Edge Cases**: Include boundary conditions and error scenarios
6. **Keep Tests Fast**: Avoid unnecessary delays or heavy operations

## Common Issues

### Test Fails Intermittently
- **Cause**: Race conditions or async issues
- **Solution**: Use `async: false` or add synchronization

### ETS Table Not Found
- **Cause**: Application not started properly
- **Solution**: Ensure supervision tree is running

### LiveView Tests Timeout
- **Cause**: Heavy operations or infinite loops
- **Solution**: Check game tick scheduling and cleanup

## Resources

- [ExUnit Documentation](https://hexdocs.pm/ex_unit/ExUnit.html)
- [Phoenix LiveView Testing](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveViewTest.html)
- [Elixir Testing Best Practices](https://elixir-lang.org/getting-started/mix-otp/docs-tests-and-with.html)

---

**Need Help?** Check the test files for examples or reach out to the community!
