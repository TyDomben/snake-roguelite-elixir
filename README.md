# 🐍 Snake Roguelite

A modern take on the classic Snake game with roguelite mechanics, built with Elixir and Phoenix LiveView as a learning project demonstrating best practices.

## 🎮 Game Features

### Core Gameplay
- **Classic Snake Mechanics**: Control your snake with arrow keys on a 20x20 grid
- **Grow & Score**: Eat food to grow longer and increase your score
- **Collision Detection**: Game over when you hit walls or yourself (unless you have Ghost Mode!)
- **Real-time Updates**: Smooth gameplay powered by Phoenix LiveView

### Roguelite Mechanics
- **Level System**: Level up every 5 food eaten
- **Upgrade Selection**: Choose 1 of 3 random upgrades each level
- **Meta Progression**: Track your high score across sessions
- **Strategic Depth**: Different upgrades create unique playstyles

### Available Upgrades
- **Speed Demon**: Move 20% faster
- **Slow and Steady**: Move 30% slower for better control
- **Ghost Mode**: Phase through your own body
- **Extra Life**: Gain one additional life
- **Double Points**: Earn 2x points from food
- **Diet Plan**: Shrink by 3 segments for easier maneuvering

## 🛠️ Tech Stack

- **Elixir**: Functional programming language for the backend
- **Phoenix Framework**: Web framework for Elixir
- **Phoenix LiveView**: Real-time server-rendered HTML (no JavaScript framework needed!)
- **GenServer**: OTP pattern for managing game state
- **Tailwind CSS**: Utility-first CSS framework for styling

## 🏗️ Architecture Highlights

This project demonstrates key Elixir/Phoenix patterns:

### GenServer for Game State
```elixir
# Each game session runs in its own GenServer process
# lib/snake_roguelite/game_server.ex
- Manages snake position, direction, and movement
- Handles collision detection and food spawning
- Tracks score, level, and active upgrades
- Immutable state updates following functional principles
```

### Phoenix LiveView for Real-time UI
```elixir
# lib/snake_roguelite_web/live/game_live.ex
- Real-time updates without writing JavaScript
- Keyboard event handling via LiveView events
- Scheduled tasks for game tick loop
- Server-side rendering with client-side interactivity
```

### Process Supervision
```elixir
# lib/snake_roguelite/application.ex
- Dynamic supervision of game sessions
- Registry for tracking active games
- Fault-tolerant architecture (if a game crashes, only that session is affected)
```

## 🚀 Getting Started

### Prerequisites
- Elixir 1.14 or later
- Erlang/OTP 25 or later

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd snake-roguelite-elixir
   ```

2. **Install dependencies**
   ```bash
   mix deps.get
   ```

3. **Install Node.js dependencies for assets**
   ```bash
   cd assets && npm install && cd ..
   ```

4. **Start the Phoenix server**
   ```bash
   mix phx.server
   ```

5. **Play the game!**
   Open your browser and visit: [`localhost:4000`](http://localhost:4000)

### Alternative: Using iex

For interactive development with Elixir's REPL:

```bash
iex -S mix phx.server
```

## 🎓 Learning Resources

This project is designed as a learning tool. Key concepts demonstrated:

### Elixir Concepts
- **Pattern Matching**: Used extensively in game logic (`move_head/2`, collision detection)
- **Immutable Data Structures**: All state updates return new state
- **Pipe Operator**: Chaining transformations cleanly
- **Enums**: Working with lists functionally

### OTP/GenServer
- **State Management**: GenServer as a stateful process
- **Client/Server Pattern**: Public API vs. private callbacks
- **Process Isolation**: Each game session is independent
- **Supervision Trees**: Fault-tolerant process hierarchy

### Phoenix LiveView
- **Server-Side Rendering**: HTML rendered on the server, pushed to client
- **Event Handling**: Keyboard and click events without JavaScript
- **Real-time Updates**: Automatic DOM patching
- **Assigns & State**: Managing view state
- **Components**: Reusable UI elements (game board, upgrade cards)

### Game Development
- **Game Loop**: Tick-based updates using `Process.send_after/3`
- **State Machine**: Game status (playing, game_over, level_up)
- **Collision Detection**: Grid-based collision logic
- **Procedural Generation**: Random food placement and upgrade selection

## 📂 Project Structure

```
snake-roguelite-elixir/
├── lib/
│   ├── snake_roguelite/
│   │   ├── application.ex          # OTP application and supervision tree
│   │   ├── game_server.ex          # GenServer for game logic
│   │   └── game_registry.ex        # Registry for game sessions
│   └── snake_roguelite_web/
│       ├── components/
│       │   ├── core_components.ex  # Reusable UI components
│       │   └── layouts/            # Page layouts
│       ├── controllers/
│       │   └── error_html.ex       # Error pages
│       ├── live/
│       │   └── game_live.ex        # Main game LiveView
│       ├── endpoint.ex             # Phoenix endpoint configuration
│       ├── router.ex               # Route definitions
│       ├── telemetry.ex            # Application metrics
│       └── snake_roguelite_web.ex  # Web module definitions
├── assets/
│   ├── css/
│   │   └── app.css                 # Tailwind CSS styles
│   ├── js/
│   │   └── app.js                  # Minimal JavaScript for LiveView
│   └── tailwind.config.js          # Tailwind configuration
├── config/
│   ├── config.exs                  # Main configuration
│   ├── dev.exs                     # Development config
│   ├── prod.exs                    # Production config
│   └── test.exs                    # Test config
└── mix.exs                         # Project dependencies
```

## 🎯 Future Enhancement Ideas

Want to extend this project? Here are some ideas:

- **Multiplayer**: Use Phoenix Channels or PubSub for competitive/cooperative modes
- **Persistence**: Add a database (PostgreSQL) to track all-time high scores
- **More Upgrades**: Create additional power-ups (teleportation, shields, etc.)
- **Difficulty Modes**: Different grid sizes, starting speeds, or rule variations
- **Sound Effects**: Add audio feedback for eating food, leveling up, etc.
- **Animations**: Smooth transitions between cells
- **Mobile Support**: Touch controls for mobile devices
- **Leaderboards**: Global or friends-only high score tracking
- **Daily Challenges**: Seeded runs with specific upgrade paths

## 🤝 Contributing

This is a learning project! Contributions, issues, and feature requests are welcome.

## 📝 License

This project is open source and available under the MIT License.

## 🙏 Acknowledgments

- Built with [Phoenix Framework](https://www.phoenixframework.org/)
- Styled with [Tailwind CSS](https://tailwindcss.com/)
- Inspired by classic Snake and modern roguelite games

---

**Happy Coding! 🎉**

Learn Elixir, have fun, and maybe beat your high score!
