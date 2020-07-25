# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :textdb,
  ecto_repos: [Textdb.Repo]

# Configures the endpoint
config :textdb, TextdbWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "i6bRp303wpNnbCK7/vn8kSz/dXVJaO+hheUJqsz9f1prWmz7URIMuBP+2iSAnQfI",
  render_errors: [view: TextdbWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Textdb.PubSub,
  live_view: [signing_salt: "Tx9d3Tzs"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
