defmodule Trex.TrackerSupervisor do
  use Supervisor
  import Trex.Url
  import Trex.Lambda

  def start_link do
    :supervisor.start_link({:local, :tracker_sup}, __MODULE__, [])
  end

  def init(_) do
    IO.inspect "starting tracker supervisor..."
    supervise([], strategy: :one_for_one)
  end

  defp unique_id(torrent_id, url) do
    :crypto.hash(:sha, "#{url}-#{torrent_id}") |> Hex.encode |> String.to_atom
  end

  def start_tracker(<<"http", _::binary>> = url, torrent) do
    #IO.inspect "starting http tracker... #{url}"
    #id = unique_id(torrent[:id], url)
    #:supervisor.start_child(:tracker_sup, worker(Trex.HttpTracker, [id, url, torrent], [id: id, strategy: :one_for_one, max_restarts: 10]))
  end

  def start_tracker(<<"udp", _::binary>> = url, torrent) do
    IO.inspect "starting udp tracker...#{url}"
    id = unique_id(torrent[:id], url)
    :supervisor.start_child(:tracker_sup, worker(Trex.UDPTracker, [id,  parse_url(url), torrent], [id: id, strategy: :one_for_one, max_restarts: 10]))
  end

end
