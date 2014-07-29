defmodule Trex do
  use Application
  alias Trex.Torrent
  alias Trex.Supervisor
  alias Trex.TrackerSupervisor
  alias Trex.PeerSupervisor
  alias Trex.TrackerList

  def version, do: 1.1


  def start(_,_) do
    IO.puts "Starting Trex supervisor..."
    HTTPotion.start
    Supervisor.start_link
  end

  #External APIs
  defp start_trackers(torrent) do
    for url <- [torrent[:announce] | torrent[:announce_list]] ++ TrackerList.all do
      TrackerSupervisor.start_tracker(url, torrent)
    end
  end

  def download(file) do
    torrent = Torrent.create(file)
    PeerSupervisor.start_peer torrent
    start_trackers torrent
  end
    

end
