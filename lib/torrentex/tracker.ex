defmodule Torrentex.Tracker do
  alias Torrentex.UDPTracker
  alias Torrentex.TrackerSupervisor

  def track(torrent) do
    case torrent[:announce] do
      <<"http", _::binary>> -> TrackerSupervisor.start_tracker(:tcp, torrent)
      <<"udp", _::binary>>  -> TrackerSupervisor.start_tracker(:udp, torrent)
    end
  end
  
end
