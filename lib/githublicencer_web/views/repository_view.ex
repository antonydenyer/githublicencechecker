defmodule GithublicencerWeb.RepositoryView do
  use GithublicencerWeb, :view

	use Phoenix.HTML

	require IEx

  def render("index.json", %{github_repos: github_repos}) do
    %{data: render_many(github_repos, GithublicencerWeb.RepositoryView, "github_repo.json")}
  end

  def render("show.json", %{github_repo: github_repo}) do
    %{data: render_one(github_repo, GithublicencerWeb.RepositoryView, "github_repo.json")}
  end

	def render("github_repo.json", %{github_repo: github_repo}) do
		%{
			id: github_repo.id,
			name: github_repo.name,
			owner: github_repo.owner,
			user_agreements: render_many(github_repo.user_agreements, GithublicencerWeb.RepositoryView, "user_agreements.json", as: :user_agreements)
		}
	end

	def render("user_agreements.json", %{user_agreements: user_agreements}) do
		%{
			id: user_agreements.id,
			is_valid: user_agreements.is_vaild
		}
	end

	def link_to(repository) do
		text = repository.owner <> "/" <> repository.name
		repository_link = "https://" <> repository.repository_type <> ".com/" <> text
		tag(:span, class: repository.repository_type)
			[
				link(text, to: repository_link)
			]
	end
end
