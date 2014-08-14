defmodule Trex.PeerSupervisor do
  use Supervisor
  alias Trex.Peer

  def start_link do
    :supervisor.start_link({:local, :peer_sup}, __MODULE__, [])
  end

  def init(_) do
    IO.inspect "starting peer supervisor..."
    supervise([], strategy: :one_for_one)
  end

  def start_peer(host, port, tpid) do
    options = [id: make_ref(), strategy: :one_for_one, max_restarts: 2, restart: :transient]
    :supervisor.start_child(:peer_sup, worker(Trex.Peer, [host, port, tpid], options))
  end

end
