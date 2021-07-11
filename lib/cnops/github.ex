defmodule Cnops.GitHub do
  @owner "kansi"

  defmodule Workflow do
    use Tesla

    plug(Tesla.Middleware.BaseUrl, "https://api.github.com")
    plug(Tesla.Middleware.FollowRedirects)

    plug(Tesla.Middleware.Headers, [
      {"accept", "application/vnd.github.v3+json"},
      {"authorization", "token #{System.fetch_env!("GITHUB_TOKEN")}"},
      {"user-agent", "Tesla"}
    ])

    plug(Tesla.Middleware.JSON)

    def list_runs(owner, repo, params) do
      get("/repos/#{owner}/#{repo}/actions/runs", query: params)
    end

    def download_artifact(url) do
      with {:ok, %Tesla.Env{body: %{"artifacts" => [artifact]}}} <- get(url),
           {:ok, %Tesla.Env{body: body}} <- get(artifact["archive_download_url"]) do
        {:ok, [{name, release_tar}]} = :zip.extract(body, [:memory])
        #  File.write("/tmp/#{name}", release_tar)
        {:ok, {name, release_tar}}
      end
    end
  end

  defmodule Commits do
    use Tesla

    plug(Tesla.Middleware.BaseUrl, "https://api.github.com")

    plug(Tesla.Middleware.Headers, [
      {"accept", "application/vnd.github.v3+json"},
      {"user-agent", "Tesla"}
    ])

    plug(Tesla.Middleware.JSON)

    def list(owner, repo, params) do
      get("/repos/#{owner}/#{repo}/commits", query: params)
    end
  end

  defmodule Repository do
    use Tesla

    plug(Tesla.Middleware.BaseUrl, "https://api.github.com")

    plug(Tesla.Middleware.Headers, [
      {"accept", "application/vnd.github.v3+json"},
      {"user-agent", "Tesla"}
    ])

    plug(Tesla.Middleware.JSON)

    def list_releases(owner, repo, params) do
      get("/repos/#{owner}/#{repo}/releases", query: params)
    end

    def list_tags(owner, repo, params) do
      get("/repos/#{owner}/#{repo}/tags", query: params)
    end
  end

  def get_latest_commit_on_master(repo) do
    {:ok, %Tesla.Env{body: commits}} = Commits.list(@owner, repo, sha: "master", per_page: 1)

    Enum.map(commits, fn commit_obj ->
      %{sha: commit_obj["sha"], timestamp: commit_obj["commit"]["author"]["date"]}
    end)
    |> hd()
  end

  def get_latest_successful_workflow_run_on_master(repo) do
    {:ok, %Tesla.Env{body: %{"workflow_runs" => runs}}} =
      Workflow.list_runs(@owner, repo, branch: "master", status: "success", per_page: 1)

    Enum.map(runs, fn run ->
      %{
        sha: run["head_sha"],
        timestamp: run["created_at"],
        artifacts_url: run["artifacts_url"]
      }
    end)
    |> hd()
  end

  def get_latest_release_sha(repo) do
    with {:ok, %Tesla.Env{body: [release]}} <-
           Repository.list_releases(@owner, repo, per_page: 1),
         {:ok, %Tesla.Env{body: tags}} <- Repository.list_tags(@owner, repo, per_page: 100) do
      tag = Enum.find(tags, fn tag -> tag["name"] == release["tag_name"] end)
      {:ok, tag["commit"]["sha"]}
    end
  end
end
