defmodule GithublicencerWeb.Commiter do
  use GithublicencerWeb, :model

  schema "commiters" do
    field :email, :string
    field :name, :string
    field :github_user_id, :integer

		field :manual_overide, :boolean

		field :sign_at, :naive_datetime
		field :signed_ip_address, :string
		field :signed_name, :string

		field :parent_commiter_id, :integer

		field :note, :string

    timestamps()

		belongs_to :github_repo, GithublicencerWeb.GithubRepo
		has_many :commits, GithublicencerWeb.Commit

  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
        :email,
        :name,
        :github_user_id,
        :github_repo_id,
        :note,
        :manual_overide,
        :sign_at,
        :parent_commiter_id,
        :signed_name,
        :signed_ip_address])
    |> validate_required([:github_user_id])
  end
end
