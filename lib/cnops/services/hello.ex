defmodule Cnops.Services.Hello do
  @release_name :hello
  @repo "hello"

  use ControlNode.Release,
    spec: %ControlNode.Release.Spec{
      name: @release_name,
      # Path to store release tar file on remote host
      base_path: "/home/cnops/hello-releases"
    }

  alias Cnops.Hosts
  alias Cnops.GitHub

  def get_namespace_spec(:production) do
    %ControlNode.Namespace.Spec{
      tag: :production,
      hosts: [Hosts.prod1_spec()],
      registry_spec: registry_spec(),
      deployment_type: :incremental_replace,
      release_cookie: :simple_cookie_4526
    }
  end

  def get_namespace_spec(:testing) do
    %ControlNode.Namespace.Spec{
      tag: :testing,
      hosts: [Hosts.test1_spec()],
      registry_spec: registry_spec(),
      deployment_type: :incremental_replace,
      release_cookie: :simple_cookie_4526
    }
  end

  def registry_spec() do
    %ControlNode.Registry.Local{path: "/tmp"}
  end

  def get_latest_release_sha(), do: GitHub.get_latest_release_sha(@repo)

  def get_latest_successful_workflow_run_on_master() do
    %{sha: sha} = GitHub.get_latest_successful_workflow_run_on_master(@repo)
    {:ok, sha}
  end

  def download_and_store_release(sha) do
    with %{artifacts_url: url} <- GitHub.get_successful_workflow_run_for_commit(@repo, sha),
         {:ok, {name, release_tar}} <- Cnops.GitHub.Workflow.download_artifact(url) do
      store_release(name, release_tar)
    end
  end

  def download_and_store_latest_master_build do
    with %{artifacts_url: url} <- GitHub.get_latest_successful_workflow_run_on_master(@repo),
         {:ok, {name, release_tar}} <- Cnops.GitHub.Workflow.download_artifact(url) do
      store_release(name, release_tar)
    end
  end

  defp store_release(name, release_tar) do
    with {:ok, vsn} <- get_vsn_from(:erlang.list_to_binary(name)) do
      ControlNode.Registry.store(registry_spec(), @release_name, vsn, release_tar)
      {:ok, vsn}
    end
  end

  defp get_vsn_from(name) do
    [_, vsn] = Regex.run(~r{^hello-(.*).tar.gz$}, name)
    {:ok, vsn}
  end

  def get_commit_from_version(version) do
    [_, sha] = String.split(version, "-")
    {:ok, sha}
  end
end
