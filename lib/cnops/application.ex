defmodule Cnops.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    :net_kernel.start([:cnops, :shortnames])
    ns_testing_hello = Cnops.Services.Hello.get_namespace_spec(:testing)
    ns_testing_hello_go = Cnops.Services.HelloGo.get_namespace_spec()

    children = [
      Cnops.Scheduler,
      %{
        id: NamespaceTestingHello,
        start: {ControlNode.Namespace, :start_link, [ns_testing_hello, Cnops.Services.Hello]}
      },
      %{
        id: NamespaceTestingHelloGo,
        start: {ControlNode.Namespace, :start_link, [ns_testing_hello_go, Cnops.Services.HelloGo]}
      }
    ]

    opts = [strategy: :one_for_one, name: Cnops.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
