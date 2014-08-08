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

  defp start(module, info_hash, url, torrent_pid) do
    args = [info_hash, url, torrent_pid]
    options = [id: make_ref(), strategy: :one_for_one, max_restarts: 10]
    :supervisor.start_child(:tracker_sup, worker(module, args, options))
  end

  def start_tracker(info_hash, <<"http", _::binary>> = url, torrent_pid) do
    #IO.inspect "starting http tracker... #{url}"
    start(Trex.HttpTracker, info_hash,url, torrent_pid)
  end

  def start_tracker(info_hash, <<"udp", _::binary>> = url, torrent_pid) do
    #IO.inspect "starting udp tracker...#{url}"
    #start(Trex.UDPTracker, info_hash,url, torrent_pid)
  end

end
