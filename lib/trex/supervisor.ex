defmodule Trex.Supervisor do
  use Supervisor.Behaviour


  def start_link do
    :supervisor.start_link(__MODULE__, [])
  end

  def init(_) do
    children = [
      worker(Trex.Server, []),
      supervisor(Trex.TrackerSupervisor, [])
    ]
    supervise(children, strategy: :one_for_one)
  end
end
