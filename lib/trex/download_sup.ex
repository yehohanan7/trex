defmodule Trex.DownloadSupervisor do
  use Supervisor.Behaviour

  def start_link do
    :supervisor.start_link({:local, :download_sup}, __MODULE__, [])
  end

  def init(_) do
    IO.inspect "starting download supervisor..."
    supervise([], strategy: :one_for_one)
  end

  def download(torrent_id, torrent) do
    IO.inspect "Supervising download worker for torrent #{inspect torrent_id} ..."
    #child process needs an ID! otherwise it uses the module name as ID!
    :supervisor.start_child(:tracker_sup, worker(Trex.DownloadWorker, [torrent_id, torrent], [id: torrent_id]))
  end

end
