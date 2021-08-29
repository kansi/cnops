defmodule Cnops.Deploy do
  require Logger
  alias Cnops.Services

  def hello_production() do
    with {:ok, vsn_list} <- ControlNode.Namespace.current_version(:production_hello),
         {:ok, vsn} <- extract_running_version(vsn_list) do
      if vsn do
        maybe_update_production(vsn)
      end
    end
  end

  defp maybe_update_production(vsn) do
    {:ok, release_sha} = Services.Hello.get_latest_release_sha()
    {:ok, current_sha} = Services.Hello.get_commit_from_version(vsn)

    if current_sha != slug(release_sha) do
      {:ok, vsn} = Services.Hello.download_and_store_release(release_sha)
      Logger.info("Deploying new production release version #{vsn}")
      ControlNode.Namespace.deploy(:production_hello, vsn)
      {:ok, vsn}
    end
  end

  def hello_go_testing() do
    with {:ok, [%{version: vsn}]} when not is_nil(vsn) <-
           ControlNode.Namespace.current_version(:testing_rubin) do
      maybe_update_testing(Services.HelloGo, :testing_rubin, vsn)
    else
      _ ->
        :ok
    end
  end

  def hello_testing() do
    # 1. current_version/1 will return :busy if its deploying
    # 2. version: nil implies that release is not running in which case we let
    #    the user manually deploy the release
    with {:ok, [%{version: vsn}]} when not is_nil(vsn) <-
           ControlNode.Namespace.current_version(:testing_hello) do
      maybe_update_testing(Services.Hello, :testing_hello, vsn)
    else
      _ ->
        :ok
    end
  end

  defp maybe_update_testing(svc_module, namespace, version) do
    {:ok, sha} = svc_module.get_commit_from_version(version)
    {:ok, master_sha} = svc_module.get_latest_successful_workflow_run_on_master()

    # If the latest release version is the same as master then noop
    if sha == slug(master_sha) do
      {:ok, :noop}
    else
      update_testing(svc_module, namespace)
    end
  end

  # update_testing(Services.Hello, :testing_hello)
  def update_testing(svc_module, namespace) do
    {:ok, vsn} = svc_module.download_and_store_latest_master_build()
    Logger.info("Deploying new release version #{vsn}")
    ControlNode.Namespace.deploy(namespace, vsn)
    {:ok, vsn}
  end

  defp extract_running_version(vsn_list) do
    vsn_list
    |> Enum.filter(fn %{version: vsn} -> not is_nil(vsn) end)
    |> Enum.uniq_by(fn %{version: vsn} -> vsn end)
    |> case do
      [] ->
        {:ok, nil}

      [%{version: vsn}] ->
        {:ok, vsn}

      vsns ->
        Logger.error("multiple version running #{inspect(vsns)}")
        {:error, :multiple_version_running}
    end
  end

  defp slug(sha), do: String.slice(sha, 0..6)
end
