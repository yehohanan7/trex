defmodule Torrentex.Scheduler do
  use GenServer.Behaviour

  #External API
  def start_link() do
    :gen_server.start_link({:local, :scheduler}, __MODULE__, [], [])
  end

  def schedule(file) do
    IO.puts "scheduling download of #{file}.."
    file
  end

  #GenServer Callbacks
  def init(_) do
    {:ok, []}
  end

  def handle_call({:schedule, file}, _from, state) do
    {:reply, file, state}
  end

end
