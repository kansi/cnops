defmodule Cnops.Hosts do
  def test1_spec() do
    gen_host_spec("34.66.203.68", "cnops-ex-eu-conf")
  end

  defp gen_host_spec(host, user) do
    %ControlNode.Host.SSH{
      host: host,
      port: 22,
      user: user,
      private_key_dir: System.fetch_env!("PRIVATE_KEY_DIR"),
      via_ssh_agent: false
    }
  end
end
