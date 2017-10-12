defmodule GithublicencerWeb.CommiterController do
  use GithublicencerWeb, :controller
  alias GithublicencerWeb.Commiter

  defp populate_parent_commiter(%Commiter{parent_commiter_id: nil} = commiter) do
    commiter
  end

  defp populate_parent_commiter(%Commiter{parent_commiter_id: _} = commiter) do
    parent_commiter = Repo.get!(Commiter, commiter.parent_commiter_id)
    Map.put commiter, :parent_commiter, parent_commiter
  end


  def show(conn, %{"repository_id" => repository_id, "id" => id}) do
    commiter =
      Repo.get!(Commiter, id)
      |> Repo.preload(:commits)
    render conn, "show.html", commiter: commiter
  end

	def sign(conn, %{"repository_id" => repository_id, "commiter_id" => commiter_id}) do
		commiter =
      Repo.get!(Commiter, commiter_id)
      |> Repo.preload(:repository)
    changeset = Commiter.changeset(commiter)
    render conn, "sign.html", commiter: commiter, changeset: changeset
  end

  def edit(conn, %{"id" => id}) do
    commiter =
      Repo.get!(Commiter, id)
      |> Repo.preload(:repository)
      |> populate_parent_commiter
    changeset = Commiter.changeset(commiter)
    render conn, "edit.html", commiter: commiter, changeset: changeset
  end


  def update(conn, %{"id" => id, "commiter" => commiter_params}) do
    commiter =
      Repo.get!(Commiter, id)
      |> Repo.preload(:repository)
		IO.puts("-------------")
		IO.inspect(commiter_params)
		commiter_params = populate_signed(conn, commiter_params)
		IO.inspect(commiter_params)
		IO.puts("-------------")
    changeset = Commiter.changeset(commiter, commiter_params)
    case Repo.update(changeset) do
      {:ok, commiter} ->
        conn
        |> put_flash(:info, "Commiter updated successfully.")
        |> redirect(to: repository_path(conn, :show, commiter.repository))

      {:error, changeset} ->
        render conn, "edit.html", commiter: commiter, changeset: changeset
    end
  end

	defp populate_signed(conn, commiter_params = %{"accept" => "true"}) do
		ip = conn.remote_ip |> Tuple.to_list |> Enum.join(".")
		Map.put(commiter_params, "signed_ip_address", ip)
		Map.put(commiter_params, "sign_at", DateTime.utc_now)
	end

	defp populate_signed(conn, commiter_params) do
	end

  def index(conn, %{ "repository_id" => repository_id, "exclude_self" => exclude_self}) do
    commiters = Repo.all(Commiter, repository_id: repository_id)
    render conn, "index.json", commiters: commiters
  end

  def index(conn, %{"repository_id" => repository_id}) do
    commiters = Repo.all(Commiter, repository_id: repository_id)
    render conn, "index.json", commiters: commiters
  end
end
