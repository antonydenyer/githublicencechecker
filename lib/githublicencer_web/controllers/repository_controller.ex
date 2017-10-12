defmodule GithublicencerWeb.RepositoryController do
	use GithublicencerWeb, :controller

	alias GithublicencerWeb.Repository

	def index(conn, _params) do
		repos = (get_session(conn, :current_user)
							|> Repo.preload(:repositories))
							.repositories


		repos = Repo.preload(repos, :commiters)

		github_repo_owner = repos |> List.first || %{} |> Map.get(:owner)

		render(conn, "index.html", repositories: repos, github_repo_owner: github_repo_owner)
	end


	def show(conn, %{"id" => id}) do

		repo = Repo.get!(Repository, id)
					|> Repo.preload(:commiters)

		commiters = repo.commiters
				|> set_valid_agreement

		render(conn, "show.html", repository: repo, commiters: commiters)
	end

	defp select_populated_commiter(commits) do
		Enum.map commits, fn(commit)->
				count = Enum.count commits, fn(sub_commit)->
					sub_commit.commiter == commit.commiter
				end
				commit |> Map.get(:commiter) |> Map.put(:commit_count, count)
		end
	end



	defp remove_nil_commiters(commiters) do
		Enum.filter commiters, fn(commiter)->
				!is_nil(commiter)
		end
	end

	defp set_valid_agreement(commiters) do
		Enum.map commiters, fn(commiter)->
				is_signed = !is_nil(commiter.sign_at) && !is_nil(commiter.signed_ip_address)
				is_valid =  is_signed || (commiter.manual_overide == true)
				Map.put(commiter, :is_valid, is_valid)
		end
	end



end
