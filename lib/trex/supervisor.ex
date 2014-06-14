defmodule Trex.Supervisor do
  use Supervisor.Behaviour
  alias Trex.PeerSupervisor
  alias Trex.TrackerSupervisor

  def start_link do
    :supervisor.start_link({:local, :trex_sup}, __MODULE__, [])
  end

  def init(_) do
    supervise([supervisor(TrackerSupervisor, []), supervisor(PeerSupervisor, [])], strategy: :one_for_one)
  end

end
