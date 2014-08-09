defmodule Trex.Torrent do
  use GenServer
  alias Trex.TrackerSupervisor
  alias Trex.TrackerList
  alias Trex.BEncoding
  import IEx

  #External API
  def start(torrent) do
    {:ok, tpid} = GenServer.start_link(__MODULE__, Dict.put(torrent, :peers, []), [])
    for url <- trackers(tpid) do
      TrackerSupervisor.start_tracker(url, tpid)
    end
  end

  def peers_found(pid, {:peers, peers}) do
    GenServer.cast(pid, {:peers, peers})
  end

  def infohash(pid) do
    :crypto.hash(:sha, BEncoding.encode(info(pid))) |> Hex.encode
  end

  def name(pid) do
    attr(pid, "name")
  end

  def trackers(pid) do
    [attr(pid, "announce") | Enum.map(attr(pid, "announce-list"), fn [v] -> v end)] ++ TrackerList.all
  end

  def files(pid) do
    multi_file_mapper = fn file -> %{length: file["length"], path: file["path"]} end
    case info(pid) do
      %{"length" => length, "name" => name} -> [%{:name => name, :length => length}]
      %{"files" => files} ->   Enum.map(files, multi_file_mapper)
    end
  end

  #private
  defp info(pid) do
    attr(pid, "info")
  end

  defp attr(pid, key) do
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
