defmodule Trex do
  use Application.Behaviour
  alias Trex.Torrent
  alias Trex.Supervisor
  alias Trex.TrackerSupervisor
  alias Trex.PeerSupervisor

  def version, do: 1.1

  @port 7771

  def start(_,_) do
    IO.puts "Starting Trex supervisor..."
    Supervisor.start_link
  end

  #External APIs
  defp start_trackers(torrent) do
    for {url, index} <- Enum.with_index([torrent[:announce] | torrent[:announce_list]]) do
      TrackerSupervisor.start_tracker(url, @port + index, torrent)
    end
    torrent
  end

  def download(file) do
    Torrent.create(file)
    |> start_trackers
    |> PeerSupervisor.start_peer
  end
    

  def status do
    "Not yet implemented"
  end

end
