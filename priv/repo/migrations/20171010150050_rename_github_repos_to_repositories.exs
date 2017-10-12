defmodule GithublicencerWeb.Repo.Migrations.RenameGithubReposToRepositories do
  use Ecto.Migration

  def change do
    rename table(:github_repos), to: table(:repositories)
    rename table(:commiters), :github_repo_id, to: :repository_id
  end
end
