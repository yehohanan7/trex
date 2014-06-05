defmodule Trex.Scheduler do
  use GenServer.Behaviour
  alias Trex.Tracker

  #External API
  def start_link() do
    :gen_server.start_link({:local, :scheduler}, __MODULE__, [], [])
  end

  def schedule(file) do
    download file
  end

  def download(file) do
    :gen_server.call :scheduler, {:download, file}
  end

  def status do
    :gen_server.call :scheduler, :status
  end

  #GenServer Callbacks
  def init(_) do
    {:ok, []}
  end

  def handle_call({:download, torrent}, _from, state) do
    IO.puts "downloading #{torrent[:name]}"
    {:reply, torrent, state}
  end

  def handle_call(:status, _from, state) do
    {:reply, "status", state}
  end

end
