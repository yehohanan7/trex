defmodule Trex.Supervisor do
  use Supervisor.Behaviour

  def start_link do
    :supervisor.start_link({:local, :trex_sup}, __MODULE__, [])
  end

  def init(_) do
    supervise([supervisor(Trex.TrackerSupervisor, [])], strategy: :one_for_one)
  end

  def start_download(file) do
    :supervisor.start_child(:trex_sup, worker(Trex.Downloader, [file], [id: file]))
  end

end
