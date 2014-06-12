defmodule Trex.TrackerSupervisor do
  use Supervisor.Behaviour

  def start_link do
    :supervisor.start_link({:local, :tracker_sup}, __MODULE__, [])
  end

  def init(_) do
    IO.inspect "starting tracker supervisor..."
    supervise([], strategy: :one_for_one)
  end

  def start_tracker(:tcp, port, tracker_host, tracker_port, peer) do    
    IO.inspect "starting tcp tracker..."
    child_id = "tcp_#{port}_#{tracker_host}_#{tracker_port}"
    :supervisor.start_child(:tracker_sup, worker(Trex.TCPTracker, [port, tracker_host, tracker_port, peer], [id: child_id]))
  end

  def start_tracker(:udp, port, tracker_host, tracker_port, peer) do    
    IO.inspect "starting udp tracker..."
    child_id = "udp_#{port}_#{tracker_host}_#{tracker_port}"
    :supervisor.start_child(:tracker_sup, worker(Trex.UDPTracker, [port, tracker_host, tracker_port, peer], [id: child_id]))
  end

end
