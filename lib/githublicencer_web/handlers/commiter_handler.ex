
defmodule GithublicencerWeb.CommiterHandler do

	alias GithublicencerWeb.Commiter
	alias GithublicencerWeb.Repo

	def upsert_committers(commits, repository) do

		committers = commits
			|> Enum.filter(
				fn(commit)->
					!is_nil(commit) && !is_nil(commit["committer"]) && !is_nil(commit["committer"]["id"])
				end)
			|> Enum.flat_map(
				fn(commit)->
						[
							%{
								github_user_id: commit["committer"]["id"],
								email: commit["commit"]["committer"]["email"],
								name: commit["commit"]["committer"]["name"]
							}
						]
				end)
			|> Enum.uniq

		committers = Enum.map committers, fn(commiter)->
			Map.put(commiter, :repository_id, repository.id)
		end

		Enum.each committers, &upsert_commiter/1

	end


	defp upsert_commiter(commiterData) do
		if !is_nil(commiterData) && !is_nil(commiterData.github_user_id) do #TODO need to deal with non github users

			case Repo.get_by(Commiter, github_user_id: commiterData[:github_user_id]) do
				nil ->
					cs = Commiter.changeset(%Commiter{}, commiterData)
					Repo.insert!(cs)
				commiter ->
					IO.puts("commiter")
					commiter
			end
		end
	end

end
