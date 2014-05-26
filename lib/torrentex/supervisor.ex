defmodule Torrentex.Supervisor do
  use Supervisor.Behaviour


  def start_link do
    :supervisor.start_link(__MODULE__, [])
  end

  def init(_) do
    children = [
      worker(Torrentex.Server, []),
      supervisor(Torrentex.TrackerSupervisor, [])
    ]
    supervise(children, strategy: :one_for_one)
  end
end
