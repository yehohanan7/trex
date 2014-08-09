defmodule Trex.Torrent do
  use GenServer
  alias Trex.TrackerSupervisor
  alias Trex.TrackerList
  alias Trex.BEncoding
  import IEx

  #External API
  def start(torrent) do
    {:ok, torrent_pid} = GenServer.start_link(__MODULE__, Dict.put(torrent, :peers, []), [])
    for url <- t_trackers(torrent_pid) do
      TrackerSupervisor.start_tracker(url, torrent_pid)
    end
  end

  def peers_found(pid, {:peers, peers}) do
    GenServer.cast(pid, {:peers, peers})
  end

  def t_infohash(pid) do
    :crypto.hash(:sha, BEncoding.encode(t_info(pid))) |> Hex.encode
  end

  def t_name(pid) do
    attr(pid, "name")
  end

  def t_trackers(pid) do
    alist = attr(pid, "announce-list")
    [attr(pid, "announce") | Enum.map(attr(pid, "announce-list"), fn [v] -> v end)] ++ TrackerList.all
  end

  def t_files(pid) do
    multi_file_mapper = fn file -> %{length: file["length"], path: file["path"]} end
    case t_info(pid) do
      %{"length" => length, "name" => name} -> [%{:name => name, :length => length}]
      %{"files" => files} ->   Enum.map(files, multi_file_mapper)
    end
  end

  #private
  defp t_info(pid) do
    GenServer.call(pid, {:get_attr, "info"})
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
