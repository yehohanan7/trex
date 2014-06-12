defmodule Trex do
  use Application.Behaviour
  alias Trex.Torrent
  alias Trex.Tracker
  alias Trex.Downloader
  alias Trex.Supervisor

  def version, do: 1.1

  def start(_,_) do
    IO.puts "Starting Trex supervisor..."
    Supervisor.start_link
  end

  #External APIs
  def download(file) do
    torrent_id = make_ref()
    torrent = Torrent.create(file)
    :downloader_ready = Downloader.download(torrent_id, torrent)
    :started_tracking = Tracker.track(torrent_id, [torrent[:announce] | torrent[:announce_list]], torrent[:info_hash])
    {:ok, {:torrent_id, torrent_id}}
  end

  def status do
    "Not yet implemented"
  end

end
