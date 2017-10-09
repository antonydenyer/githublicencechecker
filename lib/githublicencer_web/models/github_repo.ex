defmodule GithublicencerWeb.GithubRepo do

  use GithublicencerWeb, :model

  schema "github_repos" do
    field :repository_id, :integer
    field :name, :string
		field :owner, :string
		field :hook_id, :integer
		field :repository_type, :string

    timestamps()

		belongs_to :user, GithublicencerWeb.User
		has_many :commits, GithublicencerWeb.Commit
		has_many :commiter, GithublicencerWeb.Commiter

  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:repository_id, :user_id, :name, :owner, :hook_id, :repository_type])
    |> validate_required([:repository_id, :user_id])
		|> unique_constraint(:user_repositories_index)
  end
end
