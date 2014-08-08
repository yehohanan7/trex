defmodule Trex.Torrent do

  use GenServer
  alias Trex.TrackerSupervisor
  alias Trex.TrackerList

  def start(torrent) do
    {:ok, torrent_pid} = GenServer.start_link(__MODULE__, %{torrent: torrent, peers: []}, [])
    for url <- [torrent[:announce] | torrent[:announce_list]] ++ TrackerList.all do
      TrackerSupervisor.start_tracker(torrent[:info_hash], url, torrent_pid)
    end
  end
  
  def peers_found(pid, {:peers, peers}) do
    GenServer.cast(pid, {:peers, peers})
  end

  #Callbacks
  def init(torrent) do
    {:ok, torrent}
  end

  def handle_cast({:peers, peers}, state) do
    IO.inspect "#{length state[:peers]} peers found"
    {:noreply, Dict.put(state, :peers, peers ++ state[:peers])}
  end

end
