defmodule Torrentex.Tracker do
  alias Torrentex.UDPTracker

  def track(torrent) do
    case torrent[:announce] do
      <<"http", _::binary>> -> TCPTracker.track(torrent)
      <<"udp", _::binary>>  -> UDPTracker.track(torrent)
    end
  end
  
end
