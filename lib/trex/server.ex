defmodule Trex.Server do
  use GenServer.Behaviour
  alias Trex.Scheduler
  alias Trex.Parser
  alias Trex.Torrent
  alias Trex.Tracker

  #External API
  def start_link() do
    :gen_server.start_link({:local, :trex}, __MODULE__, [], [])
  end

  def download(path) do
    :gen_server.call :trex, {:download, path}
  end

  def status do
    :gen_server.call :trex, :status
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
