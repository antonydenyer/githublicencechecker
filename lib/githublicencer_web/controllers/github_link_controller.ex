defmodule GithublicencerWeb.GithubLinkController do
  alias GithublicencerWeb.Repository
  alias GithublicencerWeb.Commiter

  use GithublicencerWeb, :controller
  plug GithublicencerWeb.Plugs.RequireUser

  require IEx

  defp current_user(conn) do
    get_session(conn, :current_user)
  end

  defp client(conn) do
    Tentacat.Client.new(%{access_token: current_user(conn).access_token})
  end


  def index(conn, _params) do

    all_repositories = Tentacat.Repositories.list_mine(client(conn))

    linked_repo_names = (current_user(conn)
              |> Repo.preload(:repositories))
              .repositories

    filter = fn i -> !Enum.any?(linked_repo_names, & "#{Map.get(&1, :owner)}/#{Map.get(&1, :name)}" == i["full_name"]) end

    repositories = Enum.map(all_repositories, &Map.take(&1, ["full_name" , "fork"]))
                # |> Enum.filter(filter)

    # one day list organizations and add the hook to it
    # all_organizations = Tentacat.Organizations.list_mine(client(conn))

    changeset = %{
      repositories: repositories,
      licences: ["CLA 1", "CLA 2"]
    }
    render conn, "index.html" , changeset: changeset
  end

  defp find_or_create_hook(conn, owner, name) do
    hook = Tentacat.Hooks.list(owner, name, client(conn))
        |> Enum.find(& String.contains?(&1["config"]["url"], "hooks/github/#{owner}/#{name}"))

    if !hook do
      hook_body = %{
      "name" => "web",
      "active" => false,
      "events" => [ "push", "pull_request" ],
      "config" => %{
        "url" => "http://cla-sense.com/hooks/github/#{owner}/#{name}",
        "content_type" => "json"
      }
      }
      {_, hook} = Tentacat.Hooks.create(owner, name, hook_body, client(conn))

      hook
    end
  end

  defp find_or_create_repository(conn, owner, name) do
    user_id = current_user(conn).id
    hook = find_or_create_hook(conn, owner, name)
    github_repo = Tentacat.Repositories.repo_get(owner, name, client(conn))

    repository = (Repository
      |> where(repository_id: ^github_repo["id"])
      |> where(user_id: ^user_id)
      |> Repo.one
      || Repo.insert!(Repository.changeset(%Repository{
        repository_id: github_repo["id"],
        fork: github_repo["fork"],
        user_id: user_id,
        name: name,
        owner: owner,
        owner_id: github_repo["owner"]["id"],
        repository_type: "github",
        hook_id: hook["id"]
      })))
      |> Repo.preload(:commiters)

    repository
  end

  def create(conn, %{"github_link" => link}) do
    split = String.split(link["repository"], "/")
    owner = Enum.at(split, 0)
    name = Enum.at(split, 1)

    repository = find_or_create_repository(conn, owner, name)

    new_contributors_filter = fn contributor -> contributor["id"] != repository.owner_id && !Enum.any?(repository.commiters, & &1.github_user_id == contributor["id"]) end
    map_contributor_to_commiter_changeset = fn contributor -> Commiter.changeset(%Commiter{
      name: contributor["login"],
      github_user_id: contributor["id"] ,
      repository_id: repository.id,
    }) end
    multi_insert = fn {changeset, index}, multi -> Ecto.Multi.insert(multi, index, changeset) end

    new_contributors = Tentacat.Repositories.Contributors.list(owner, name, client(conn))
                        |> Enum.filter(new_contributors_filter)
                        |> Enum.map(map_contributor_to_commiter_changeset)
                        |> Enum.with_index
                        |> Enum.reduce(Ecto.Multi.new, multi_insert)


    Repo.transaction(new_contributors)


    redirect(conn, to: github_link_path(conn, :index))
  end

end