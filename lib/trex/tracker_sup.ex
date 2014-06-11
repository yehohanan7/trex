defmodule Trex.TrackerSupervisor do
  use Supervisor.Behaviour

  def start_link do
    :supervisor.start_link({:local, :tracker_sup}, __MODULE__, [])
  end

  def init(_) do
    IO.inspect "starting tracker supervisor..."
    supervise([], strategy: :one_for_one)
  end

  def start_tracker(:tcp, port, url, torrent) do    
    :supervisor.start_child(:tracker_sup, worker(Trex.TCPTracker, [port, torrent], []))
  end

  def start_tracker(:udp, port, url, torrent) do
    IO.inspect "starting udp tracker..."
    IO.inspect :supervisor.start_child(:tracker_sup, worker(Trex.UDPTracker, [port, torrent, url], [id: "#{url}_#{port}"]))
  end

end
