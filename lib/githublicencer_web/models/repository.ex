defmodule GithublicencerWeb.Repository do

  use GithublicencerWeb, :model

  schema "repositories" do
    field :repository_id, :integer
    field :fork, :boolean
    field :name, :string
		field :owner, :string
		field :hook_id, :integer
		field :owner_id, :integer
		field :repository_type, :string

    timestamps()

		belongs_to :user, GithublicencerWeb.User
		has_many :commiters, GithublicencerWeb.Commiter

  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:repository_id, :user_id, :name, :owner, :hook_id, :repository_type, :fork, :owner_id])
    |> validate_required([:repository_id, :user_id])
		|> unique_constraint(:user_repositories_index)
  end
end
