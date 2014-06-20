defmodule Trex.TrackerSupervisor do
  use Supervisor.Behaviour
  import Trex.Lambda

  def start_link do
    :supervisor.start_link({:local, :tracker_sup}, __MODULE__, [])
  end

  def init(_) do
    IO.inspect "starting tracker supervisor..."
    supervise([], strategy: :one_for_one)
  end

  def start_tracker(url, module, torrent) do
    id = string_to_atom("#{url}_#{torrent[:id]}")
    :supervisor.start_child(:tracker_sup, worker(module, [id, url, torrent], [id: id]))
  end

  def start_tracker(<<"http", _::binary>> = url, torrent) do
    IO.inspect "starting tcp tracker... #{url}"
    start_tracker(url, Trex.TCPTracker, torrent)
  end

  def start_tracker(<<"udp", _::binary>> = url, torrent) do
    IO.inspect "starting udp tracker...#{url}"
    start_tracker(url, Trex.UDPTracker, torrent)
  end

end
