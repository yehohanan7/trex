defmodule Torrentex.Server do
  use GenServer.Behaviour
  alias Torrentex.Scheduler
  alias Torrentex.Parser
  alias Torrentex.TFile

  #External API
  def start_link() do
    :gen_server.start_link({:local, :torrentex}, __MODULE__, [], [])
  end

  #GenServer Callbacks
  def init(_) do
    {:ok, []}
  end

  def handle_call({:download, file}, _from, state) do
    file |> TFile.create |> Scheduler.schedule
    {:reply, file, state}
  end


  def handle_call(:status, _from, state) do
    {:reply, Scheduler.status, state}
  end

end
