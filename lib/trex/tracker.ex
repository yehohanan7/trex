defmodule Trex.Tracker do
  use GenServer.Behaviour
  alias Trex.TrackerSupervisor

  @port 7778

  #External API
  def start_link() do
    :gen_server.start_link({:local, :tracker}, __MODULE__, [], [])
  end

  def track(torrent_id, tracker_urls, info_hash) do
    :gen_server.call(:tracker, {:track, torrent_id, tracker_urls, info_hash})
  end

  #GenServer Callbacks
  def init(_) do
    IO.inspect "Tracker starting starting..."
    {:ok, []}
  end


  def start_tracker(port, url, info_hash) do
    case url do
      <<"http", _::binary>> -> TrackerSupervisor.start_tracker(:tcp, port, url, info_hash)
      <<"udp", _::binary>>  -> TrackerSupervisor.start_tracker(:udp, port, url, info_hash)
    end
  end


  def handle_call({:track, torrent_id, tracker_urls, info_hash}, _from, state) do
    IO.inspect "Starting trackers for torrent #{inspect torrent_id}"
    for {url, index} <- Enum.with_index(tracker_urls), do: start_tracker(@port + index, url, info_hash)
    {:reply, :started_tracking, state}
  end

end
