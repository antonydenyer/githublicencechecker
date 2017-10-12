defmodule GithublicencerWeb.Router do
  use GithublicencerWeb, :router

  require Ueberauth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

	scope "/github", GithublicencerWeb do
		pipe_through :api

		post "/webhook", WebhookController, :webhook
	end

  scope "/", GithublicencerWeb do

    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index


    resources "/github/link", GithubLinkController

		resources "/pullrequests", PullrequestController
		resources "/repositories", RepositoryController do
			resources "/commiters", CommiterController do
				get "/sign", CommiterController, :sign
			end
		end
		resources "/commits", CommitController, except: [:new, :edit]

  end


	scope "/auth", GithublicencerWeb do
		pipe_through [:browser]

		get "/:provider", AuthController, :request
		get "/:provider/callback", AuthController, :callback
		post "/:provider/callback", AuthController, :callback
		delete "/logout", AuthController, :delete
	end

  # Other scopes may use custom stacks.
  # scope "/api", GithublicencerWeb do
  #   pipe_through :api
  # end
end
