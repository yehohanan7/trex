defmodule Trex.Tracker do
  alias Trex.UDPTracker
  alias Trex.TrackerSupervisor

  @port 8888

  def start_tracker(port, url, torrent) do
    case url do
      <<"http", _::binary>> -> TrackerSupervisor.start_tracker(:tcp, port, url, torrent)
      <<"udp", _::binary>> = url -> TrackerSupervisor.start_tracker(:udp, port, url, torrent)
    end
  end

  def track(torrent) do
    tracker_urls = [torrent[:announce] | torrent[:announce_list]]
    for {url, index} <- Enum.with_index(tracker_urls), do: start_tracker(@port + index, url, torrent)
    torrent
  end
  
end
