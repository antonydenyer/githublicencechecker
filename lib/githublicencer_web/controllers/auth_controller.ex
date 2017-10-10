defmodule GithublicencerWeb.AuthController do

	use GithublicencerWeb, :controller
	require IEx
	plug Ueberauth
	alias Ueberauth.Strategy.Helpers

	alias GithublicencerWeb.User

	def request(conn, _params) do
		render(conn, "request.html", callback_url: Helpers.callback_url(conn))
	end

	def delete(conn, _params) do
		conn
		|> put_flash(:info, "You have been logged out!")
		|> configure_session(drop: true)
		|> redirect(to: "/")
	end

	def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
		conn
		|> put_flash(:error, "Failed to authenticate.")
		|> redirect(to: "/")
	end



	def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
		case find_or_create(auth) do
			{:ok, user} ->
				conn
				|> put_flash(:info, "Successfully authenticated.")
				|> put_session(:current_user, user)
				|> redirect(to: "/")
			{:error, reason} ->
				conn
				|> put_flash(:error, reason)
				|> redirect(to: "/")
		end
	end

	defp find_or_create(auth) do

    user = User
			|> where(provider: ^"#{auth.provider}")
			|> where(provider_id: ^auth.extra.raw_info.user["id"])
			|> Repo.one
			|| %User{}

		params =  %{
			provider: "#{auth.provider}",
			provider_id: auth.extra.raw_info.user["id"],
			provider_username: auth.uid,
			name: auth.info.name,
			email: auth.info.email,
			avatar_url: auth.info.urls.avatar_url,
			access_token: auth.credentials.token
		}

		case Repo.insert_or_update(User.changeset(user, params)) do
			{:ok, user} ->
				{:ok, user}
			{:error, changeset} ->
				{:error, changeset}
		end
	end


end
