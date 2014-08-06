defmodule Trex.Torrent do

  use GenServer
  alias Trex.TrackerSupervisor
  alias Trex.TrackerList

  def start(torrent) do
    torrent_pid = GenServer.start_link(__MODULE__, torrent, [])
    for url <- [torrent[:announce] | torrent[:announce_list]] ++ TrackerList.all do
      TrackerSupervisor.start_tracker(torrent[:info_hash], url, torrent_pid)
    end
  end
  
  def peers_found({:peers, peers}) do
    IO.inspect "yo! peers found..."
    IO.inspect peers
  end

  #Callbacks
  def init(torrent) do
    {:ok, torrent}
  end

  def handle_cast({:peers_found, peers}, state) do
    IO.inspect "peers found!"
    IO.inspect peers
    {:noreply, state}
  end

end
