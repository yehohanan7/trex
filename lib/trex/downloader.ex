defmodule Trex.Downloader do
  use GenServer.Behaviour
  alias Trex.Torrent
  alias Trex.Tracker

  #External API
  def start_link(file) do
    :gen_server.start_link(__MODULE__, file, [])
  end


  #GenServer Callbacks
  def init(file) do
    IO.inspect "adding #{file} for download.."
    {:ok, file |> Torrent.create |> Tracker.track}
  end

end
