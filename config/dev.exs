import Config

# For development, we disable any cache and enable
# debugging and code reloading.
config :snake_roguelite, SnakeRogueliteWeb.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "snake_development_secret_key_base_needs_to_be_at_least_64_bytes",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:snake_roguelite, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:snake_roguelite, ~w(--watch)]}
  ]

# Watch static and templates for browser reloading.
config :snake_roguelite, SnakeRogueliteWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"lib/snake_roguelite_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime
