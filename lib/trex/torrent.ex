defmodule Trex.Torrent do
  use GenServer
  alias Trex.TrackerSupervisor
  alias Trex.TrackerList
  alias Trex.BEncoding

  #External API
  def start(torrent) do
    IO.inspect torrent
    {:ok, tpid} = GenServer.start_link(__MODULE__, Dict.put(torrent, :peers, []), [])
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
    files = case info(pid) do
      %{"files" => files} -> files 
      file -> [file]
    end
    Enum.map(files, fn file -> %{length: file["length"], path: file["path"]} end)
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

  def handle_cast({:peers, peers}, state) do
    IO.inspect "#{length state[:peers]} peers found"
    {:noreply, Dict.put(state, :peers, peers ++ state[:peers])}
  end

  def handle_call({:get_attr, key}, _from, state) do
    {:reply, state[key], state}
  end

end
