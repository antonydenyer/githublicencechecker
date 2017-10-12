defmodule GithublicencerWeb.BreadcrumbView do

	use GithublicencerWeb, :view

	def render("breadcrumbs.html", %{repository: repository, commiter: commiter, conn: conn}) do
		breadcrumbs =
			~s(<ol class="breadcrumb">
						<li><a href="#{repository_path(conn, :index)}">#{repository.owner}</a></li>
						<li><a href="#{repository_path(conn, :show, repository)}">#{repository.name}</a></li>
						<li class="active">#{commiter.name}</li>
			</ol>)
		raw(breadcrumbs)
	end

	def render("breadcrumbs.html", %{repository: repository, conn: conn}) do
		breadcrumbs =
			~s(<ol class="breadcrumb">
						<li><a href="#{repository_path(conn, :index)}">#{repository.owner}</a></li>
						<li><a class="active" href="#{repository_path(conn, :show, repository)}">#{repository.name}</a></li>
			</ol>)
		raw(breadcrumbs)
	end

	def render("breadcrumbs.html", %{owner: owner, conn: conn}) do
		breadcrumbs =
			~s(<ol class="breadcrumb">
						<li><a href="#{repository_path(conn, :index)}">#{owner}</a></li>
			</ol>)
		raw(breadcrumbs)
	end

end
