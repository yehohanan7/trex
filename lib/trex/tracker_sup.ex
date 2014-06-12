defmodule Trex.TrackerSupervisor do
  use Supervisor.Behaviour

  def start_link do
    :supervisor.start_link({:local, :tracker_sup}, __MODULE__, [])
  end

  def init(_) do
    IO.inspect "starting tracker supervisor..."
    supervise([], strategy: :one_for_one)
  end

  def start_tracker(:tcp, port, url, info_hash) do    
    :supervisor.start_child(:tracker_sup, worker(Trex.TCPTracker, [port, url, info_hash], []))
  end

  def start_tracker(:udp, port, url, info_hash) do
    IO.inspect "starting udp tracker..."
    #child process needs an ID! otherwise it uses the module name as ID!
    :supervisor.start_child(:tracker_sup, worker(Trex.UDPTracker, [port, url, info_hash], [id: url]))
  end

end
