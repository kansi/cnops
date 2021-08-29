defmodule Cnops.Hosts do
  def test1_spec() do
    gen_host_spec("34.66.203.68")
  end

  def prod1_spec() do
    gen_host_spec("34.69.107.68")
  end

  defp gen_host_spec(host) do
    %ControlNode.Host.SSH{
      host: host,
      port: 22,
      user: System.fetch_env!("SSH_USER"),
      private_key_dir: System.fetch_env!("PRIVATE_KEY_DIR"),
      via_ssh_agent: false
    }
  end
end
