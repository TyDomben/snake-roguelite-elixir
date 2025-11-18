# Changelog

All notable changes and improvements to the Snake Roguelite project.

## [0.2.0] - Production-Ready Release

### 🐛 Critical Bug Fixes

#### High Score Persistence
- **Fixed**: High scores now persist across game sessions using ETS
- **Added**: `HighScoreManager` module with GenServer and ETS backend
- **Impact**: Players' high scores are now preserved when restarting the game
- **Files**: `lib/snake_roguelite/high_score_manager.ex`

#### Atom Conversion Safety
- **Fixed**: Potential crash when selecting upgrades with invalid IDs
- **Changed**: Safe atom conversion with error handling in `GameLive`
- **Impact**: Game no longer crashes on malformed upgrade selection events
- **Files**: `lib/snake_roguelite_web/live/game_live.ex`

### ✨ New Features

#### Session Management
- **Added**: Automatic cleanup of GameServer processes when LiveView disconnects
- **Added**: `terminate/2` callback in GameLive
- **Impact**: Prevents memory leaks from orphaned game processes
- **Files**: `lib/snake_roguelite_web/live/game_live.ex`

#### Error Pages
- **Added**: Custom 404 and 500 error pages with game theme
- **Impact**: Better user experience when errors occur
- **Files**: `lib/snake_roguelite_web/controllers/error_html/`

### 🧪 Testing Improvements

#### Comprehensive Test Suite
- **Added**: Full test coverage for `GameServer`
  - Initial state validation
  - Movement mechanics
  - Collision detection
  - Direction changes
  - Restart functionality
- **Added**: Tests for `HighScoreManager`
  - Score persistence
  - Multiple players
  - Score updates
- **Added**: LiveView integration tests
  - Mount and rendering
  - Component visibility
  - Event handling
- **Files**: `test/snake_roguelite/`, `test/snake_roguelite_web/`

### 📚 Documentation

#### Internationalization Support
- **Added**: Gettext configuration for i18n
- **Added**: Default locale files
- **Files**: `lib/snake_roguelite_web/gettext.ex`, `priv/gettext/`

#### Code Documentation
- **Improved**: Added comprehensive comments to HighScoreManager
- **Improved**: Better error handling documentation
- **Improved**: Test documentation with clear assertions

### 🏗️ Architecture Improvements

#### Supervision Tree
- **Added**: `HighScoreManager` to application supervision tree
- **Impact**: High scores survive application restarts
- **Files**: `lib/snake_roguelite/application.ex`

#### Process Management
- **Improved**: Better lifecycle management for game sessions
- **Improved**: Proper cleanup on disconnect
- **Impact**: More reliable and efficient resource usage

### 🎨 Code Quality

#### Error Handling
- **Added**: Graceful handling of invalid upgrade IDs
- **Added**: Logging for debugging invalid operations
- **Added**: Try/rescue blocks for atom conversion

#### Best Practices
- **Applied**: Proper Elixir/OTP patterns throughout
- **Applied**: Immutable data structures
- **Applied**: Pattern matching for control flow
- **Applied**: Supervision for fault tolerance

## [0.1.0] - Initial Release

### Features
- Classic snake game mechanics
- Roguelite upgrade system
- Phoenix LiveView real-time rendering
- GenServer-based game state management
- 6 unique upgrades
- Level progression system
- Tailwind CSS styling

---

## Notes

### Breaking Changes
None in this release. All changes are backwards compatible.

### Migration Guide
No migration needed. Simply pull the latest changes and restart your server.

### Known Issues
None at this time.

### Contributors
- Built with ❤️ as a learning project for Elixir and Phoenix LiveView
