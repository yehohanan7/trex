defmodule Torrentex.Repo do
  use GenServer.Behaviour

  #External API
  def start_link() do
    :gen_server.start_link({:local, :repo}, __MODULE__, [], [])
  end

  def add(file) do
    :gen_server.call(:repo, {:add, file})
  end

  def status do
    :gen_server.call(:repo, :status)
  end

  #GenServer Callbacks
  def init(_) do
    {:ok, []}
  end

  def handle_call({:add, file}, _from, files) do
    {:reply, file, [file | files]}
  end

  def handle_call(:all, _from, files) do
    {:reply, files}
  end

  def handle_call(:status, _from, files) do
    {:reply, "no of files getting downloading : #{length files}", files}
  end

end
