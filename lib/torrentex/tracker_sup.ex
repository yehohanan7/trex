defmodule Torrentex.TrackerSupervisor do
  use Supervisor.Behaviour

  @udp_port 9998
  @tcp_port 9999

  def start_link do
    :supervisor.start_link({:local, :tracker_sup}, __MODULE__, [])
  end

  def init(_) do
    IO.inspect "starting tracker supervisor..."
    supervise([], strategy: :one_for_one)
  end

  def start_tracker(:tcp, torrent) do    
    :supervisor.start_child(:tracker_sup, worker(Torrentex.TCPTracker, [@tcp_port, torrent], []))
  end

  def start_tracker(:udp, torrent) do
    IO.inspect "starting udp tracker..."
    IO.inspect worker(Torrentex.UDPTracker, [@udp_port, torrent], [])
    :supervisor.start_child(:tracker_sup, worker(Torrentex.UDPTracker, [@udp_port, torrent], []))
  end

end
