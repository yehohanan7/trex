defmodule Torrentex.Supervisor do
  use Supervisor.Behaviour

  def start_link do
    :supervisor.start_link(__MODULE__, [])
  end

  def init(_) do
    children = [
      worker(Torrentex.Server, []),
      worker(Torrentex.Repo, []),
      worker(Torrentex.Scheduler, [])
    ]
    supervise(children, strategy: :one_for_one)
  end
end
