defmodule Torrentex.Server do
  use GenServer.Behaviour

  #External API
  def start_link() do
    :gen_server.start_link({:local, :torrentex}, __MODULE__, [], [])
  end

  #GenServer Callbacks
  def init(_) do
    {:ok, []}
  end

  def handle_call({:download, file}, _from, state) do
    file |> Torrentex.Parser.parse |> Torrentex.Scheduler.schedule
    {:reply, file, state}
  end

  def handle_call(:status, _from, state) do
    {:reply, Torrentex.Scheduler.status, state}
  end

end
