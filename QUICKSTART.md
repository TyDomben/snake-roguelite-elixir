# Quick Start Guide

Get the Snake Roguelite game running in 5 minutes!

## Prerequisites Check

```bash
# Check if you have Elixir installed
elixir --version
# You need Elixir 1.14+ and Erlang/OTP 25+

# Check if you have Node.js (for assets)
node --version
# You need Node.js 16+
```

## Installation Steps

### 1. Install Dependencies

```bash
# Install Elixir dependencies
mix deps.get

# Install Node.js dependencies for assets
cd assets && npm install && cd ..
```

### 2. Set Up Assets

```bash
# This compiles Tailwind CSS and esbuild
mix assets.setup
mix assets.build
```

### 3. Start the Server

```bash
# Start Phoenix server
mix phx.server

# Or start with interactive Elixir shell
iex -S mix phx.server
```

### 4. Play!

Open your browser to: **http://localhost:4000**

Use arrow keys to control the snake!

## Troubleshooting

### "mix: command not found"

You need to install Elixir. On Ubuntu/Debian:

```bash
sudo apt-get update
sudo apt-get install elixir erlang-dev erlang-parsetools
```

On macOS with Homebrew:

```bash
brew install elixir
```

### "npm: command not found"

Install Node.js:
- Ubuntu/Debian: `sudo apt-get install nodejs npm`
- macOS: `brew install node`
- Or download from: https://nodejs.org/

### Port 4000 already in use

Change the port in `config/dev.exs`:

```elixir
config :snake_roguelite, SnakeRogueliteWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4001],  # Changed to 4001
```

### Assets not loading

Make sure you've run:

```bash
mix assets.setup
mix assets.build
```

## Development Tips

### Auto-reload

The server automatically reloads when you change Elixir files. Just save and refresh!

### Format Code

```bash
mix format
```

### Run Tests

```bash
mix test
```

### Interactive Console

```bash
iex -S mix phx.server

# Then you can interact with the game server:
iex> SnakeRoguelite.GameServer.get_state("test-session")
```

## Next Steps

- Read the full [README.md](README.md) for architecture details
- Explore `lib/snake_roguelite/game_server.ex` for game logic
- Check out `lib/snake_roguelite_web/live/game_live.ex` for LiveView patterns
- Try adding your own upgrades!

## Game Controls

- **Arrow Keys**: Move the snake
- **Play Again Button**: Restart after game over
- **Click Upgrade Cards**: Select upgrades when leveling up

Enjoy! 🐍🎮
