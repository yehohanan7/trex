defmodule Torrentex.Server do
  use GenServer.Behaviour

  #External API
  def start_link(files \\ []) do
    :gen_server.start_link({:local, :torrentex}, __MODULE__, files, [])
  end

  #GenServer Callbacks

  def init(files) do
    {:ok, files}
  end

  def handle_call({:download, file}, _from, files) do
    {:reply, file, [file | files]}
  end

  def handle_call({:status, file}, _from, files) do
    {:reply, "torrent #{file} is getting downloaded", files}
  end

  def handle_call(:pending, _from, files) do
    {:reply, files, files}
  end

end
