defmodule GithublicencerWeb.Repo.Migrations.EnableMultiProviderForUser do
  use Ecto.Migration

  def change do
    alter table(:user) do
			add :provider, :string
      add :provider_id, :integer
    end

    rename table(:user), :github_id, to: :provider_username

  end
end
