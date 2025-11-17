import Config

# We don't run a server during test.
config :snake_roguelite, SnakeRogueliteWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "snake_test_secret_key_base_needs_to_be_at_least_64_bytes_long",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
