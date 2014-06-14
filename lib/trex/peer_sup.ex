defmodule Trex.PeerSupervisor do
  use Supervisor.Behaviour
  import Trex.Lambda

  #External API
  def start_peer(torrent) do    
    :supervisor.start_child(:peer_sup, worker(Trex.Peer, [torrent[:id], torrent], [id: torrent[:id]]))
  end

  #Supervisor callback
  def start_link do
    :supervisor.start_link({:local, :peer_sup}, __MODULE__, [])
  end

  def init(_) do
    IO.inspect "starting peer supervisor..."
    supervise([], strategy: :one_for_one)
  end

end
