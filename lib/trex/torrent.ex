defmodule Trex.Torrent do
  use GenServer
  alias Trex.TrackerSupervisor
  alias Trex.TrackerList
  alias Trex.BEncoding
  alias Trex.Peer

  #External API
  def start(torrent) do
    {:ok, tpid} = GenServer.start_link(__MODULE__, Dict.put(torrent, :peers, HashSet.new), [])
    for url <- trackers(tpid) do
      TrackerSupervisor.start_tracker(url, tpid)
    end
  end

  def update_peers(pid, {:peers, peers}) do
    GenServer.cast(pid, {:peers, peers})
  end

  def infohash(pid) do
    :crypto.hash(:sha, BEncoding.encode(info(pid))) |> Hex.encode
  end

  def name(pid) do
    value(pid, "name")
  end

  def trackers(pid) do
    [value(pid, "announce") | Enum.map(value(pid, "announce-list"), fn [v] -> v end) ++ TrackerList.all]
  end

  def files(pid) do
    case info(pid) do
      %{"files" => files} -> files
      file -> [file]
    end
    |> Enum.map(fn file -> %{length: file["length"], path: file["path"]} end)
  end

  #private
  defp info(pid) do
    value(pid, "info")
  end

  defp value(pid, key) do
    GenServer.call(pid, {:get_attr, key})
  end

  #Callbacks
  def init(torrent) do
    {:ok, torrent}
  end

  def handle_cast({:peers, new_peers}, %{peers: peers} = state) do
    is_not_member? = fn peer -> not(Set.member?(peers, peer)) end
    start = fn peer -> Peer.start(peer, self()); peer end
    update_state = fn peers -> {:noreply, Dict.put(state, :peers, peers)} end

    new_peers
    |> Stream.filter is_not_member?
    |> Stream.map start
    |> Enum.into(peers)
    |> update_state.()

  end

  def handle_call({:get_attr, key}, _from, state) do
    {:reply, state[key], state}
  end

end
