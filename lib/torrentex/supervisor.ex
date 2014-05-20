defmodule Torrentex.Supervisor do
  use Supervisor.Behaviour

  @udp_port 9998
  @tcp_port 9999

  def start_link do
    :supervisor.start_link(__MODULE__, [])
  end

  def init(_) do
    children = [
      worker(Torrentex.Server, []),
      worker(Torrentex.UDPTracker, [@udp_port])
    ]
    supervise(children, strategy: :one_for_one)
  end
end
