import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :tilewars, TilewarsWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "YNwdqQF8jXUEjqodr3NTZqNRO+NMvI4KHNES1Acg5uDArDNsi1zb0J8DkJ7+BKvH",
  server: false

# In test we don't send emails.
config :tilewars, Tilewars.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
