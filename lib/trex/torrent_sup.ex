defmodule Trex.TorrentSupervisor do
  use Supervisor
  import Trex.Parser
  import Trex.Lambda

  #External API
  def start_child(torrent) do    
    IO.inspect "starting a torrent process..."
    :supervisor.start_child(:torrent_sup, worker(Trex.Torrent, [torrent], [id: torrent[:id]]))
  end

  #Supervisor callback
  def start_link do
    :supervisor.start_link({:local, :torrent_sup}, __MODULE__, [])
  end

  def init(_) do
    IO.inspect "starting peer supervisor..."
    supervise([], strategy: :one_for_one)
  end

end
