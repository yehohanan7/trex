defmodule Torrentex.Scheduler do
  use GenServer.Behaviour
  alias Torrentex.Repo
  alias Torrentex.TFile

  #External API
  def start_link() do
    :gen_server.start_link({:local, :scheduler}, __MODULE__, [], [])
  end

  def schedule(file) do
    file
    |> Repo.add
    |> download
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

  def handle_call({:download, file}, _from, state) do
    IO.puts "downloading #{TFile.name(file)}"
    {:reply, file, state}
  end

  def handle_call(:status, _from, state) do
    {:reply, Repo.status, state}
  end

end
