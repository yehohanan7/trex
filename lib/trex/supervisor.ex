defmodule Trex.Supervisor do
  use Supervisor.Behaviour

  def start_link do
    :supervisor.start_link({:local, :trex_sup}, __MODULE__, [])
  end

  def init(_) do
    supervise([supervisor(Trex.TrackerSupervisor, []),
               supervisor(Trex.DownloadSupervisor, []),
               worker(Trex.Downloader, []),
               worker(Trex.Tracker, [])], strategy: :one_for_one)
  end

  def start_download(torrent_id, torrent) do
    :supervisor.start_child(:trex_sup, worker(Trex.DownloadWorker, [torrent_id, torrent], [id: torrent_id]))
  end

end
