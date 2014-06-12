defmodule Trex.DownloadWorker do
  use GenServer.Behaviour

  #External API
  def start_link(torrent_id, torrent) do
    :gen_server.start_link(__MODULE__, {torrent_id, torrent}, [])
  end

  #GenServer Callbacks
  def init({torrent_id, torrent} = state) do
    IO.inspect "Download worker starting for torrent #{torrent_id}"
    {:ok, :download, state, 0}
  end

  def handle_info(:download, {torrent_id, torrent}) do
    IO.inspect "ready to pull pieces for #{torrent_id}"
  end

end
