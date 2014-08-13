defmodule Trex.Supervisor do
  use Supervisor
  alias Trex.TorrentSupervisor
  alias Trex.TrackerSupervisor
  alias Trex.PeerSupervisor

  def start_link do
    :supervisor.start_link({:local, :trex_sup}, __MODULE__, [])
  end

  def init(_) do
    supervise([supervisor(PeerSupervisor, []), supervisor(TrackerSupervisor, []), supervisor(TorrentSupervisor, [])], strategy: :one_for_one)
  end

end
