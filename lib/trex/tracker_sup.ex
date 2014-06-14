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

  def start_tracker(<<"http", _::binary>> = url, port, torrent) do
    IO.inspect "starting tcp tracker..."
    id = string_to_atom("#{url}_#{torrent[:id]}")
    :supervisor.start_child(:tracker_sup, worker(Trex.TCPTracker, [id, port, url, torrent], [id: id]))
  end

  def start_tracker(<<"udp", _::binary>> = url, port, torrent) do
    IO.inspect "starting udp tracker..."
    id = string_to_atom("#{url}_#{torrent[:id]}")
    :supervisor.start_child(:tracker_sup, worker(Trex.UDPTracker, [id, port, url, torrent], [id: id]))
  end


end
