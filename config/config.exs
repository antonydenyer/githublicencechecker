# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :GithublicencerWeb,
  ecto_repos: [GithublicencerWeb.Repo]

# Configures the endpoint
config :GithublicencerWeb, GithublicencerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "MazceK6jVedNNPvQvUFiZMF08OjLe7lX47nLbGD0zj9pxCfI37nwfxH2AY24HJNq",
  render_errors: [view: GithublicencerWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: GithublicencerWeb.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :tentacat, :access_token, "306c871c7024b0583cf6e3ac63e48089c0d1840d"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :ueberauth, Ueberauth,
	  providers: [
	    github: { Ueberauth.Strategy.Github, [default_scope: "user:email,repo,admin:repo_hook,read:org, admin:org_hook"] }
	  ]

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: System.get_env("GITHUB_CLIENT_ID"),
  client_secret: System.get_env("GITHUB_CLIENT_SECRET")
# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
