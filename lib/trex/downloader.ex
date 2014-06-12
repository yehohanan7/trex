defmodule Trex.Downloader do
  use GenServer.Behaviour
  alias Trex.DownloadSupervisor

  #External API
  def start_link() do
    :gen_server.start_link({:local, :downloader}, __MODULE__, [], [])
  end

  def download(torrent_id, torrent) do
    IO.inspect torrent_id
    :gen_server.call(:downloader, {:download, torrent_id, torrent})
  end


  #GenServer Callbacks
  def init(_) do
    IO.inspect "Downloader starting..."
    {:ok, %{}}
  end


  def handle_call({:download, torrent_id, torrent}, _from, state) do
    IO.inspect "downloader ready for #{inspect torrent_id}"
    download_id = DownloadSupervisor.download(torrent_id, torrent)
    {:reply, :downloader_ready, Dict.put(state, torrent_id, {download_id, torrent})}  
  end

end
