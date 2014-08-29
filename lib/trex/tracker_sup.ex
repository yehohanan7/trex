defmodule Trex.TrackerSupervisor do
  use Supervisor

  def start_link do
    :supervisor.start_link({:local, :tracker_sup}, __MODULE__, [])
  end

  def init(_) do
    IO.inspect "starting tracker supervisor..."
    supervise([], strategy: :one_for_one)
  end

  defp start(module, url, torrent_pid) do
    args = [url, torrent_pid]
    options = [id: make_ref(), strategy: :one_for_one, restart: :transient]
    :supervisor.start_child(:tracker_sup, worker(module, args, options))
  end

  def start_tracker(<<"http", _::binary>> = url, torrent_pid) do
    IO.inspect "starting http tracker... #{url}"
    start(Trex.HttpTracker, url, torrent_pid)
  end

  def start_tracker(<<"udp", _::binary>> = url, torrent_pid) do
    IO.inspect "starting udp tracker...#{url}"
    start(Trex.UDPTracker, url, torrent_pid)
  end

end
