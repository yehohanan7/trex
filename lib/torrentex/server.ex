defmodule Torrentex.Server do
  use GenServer.Behaviour
  alias Torrentex.Scheduler
  alias Torrentex.Parser
  alias Torrentex.Torrent
  alias Torrentex.Tracker

  #External API
  def start_link() do
    :gen_server.start_link({:local, :torrentex}, __MODULE__, [], [])
  end

  def download(path) do
    :gen_server.call :torrentex, {:download, path}
  end

  def status do
    :gen_server.call :torrentex, :status
  end

  #GenServer Callbacks
  def init(_) do
    {:ok, []}
  end

  def handle_call({:download, path}, _from, state) do
    path
    |> Torrent.create
    |> Tracker.track
    {:reply, "Added for downloading", state}
  end


  def handle_call(:status, _from, state) do
    {:reply, Scheduler.status, state}
  end

end
