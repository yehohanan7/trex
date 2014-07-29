defmodule Trex.TrackerRepo do
  use GenServer

  #External API
  def start_link() do
    :gen_server.start_link({:local, :tracker_repo}, __MODULE__, [], [])
  end

  def add_peer(info_hash, peer) do
    :gen_server.call(:repo, {:add_peer, info_hash, peer})
  end

  #GenServer Callbacks
  def init(_) do
    :ets.new(:peers, [:bag, :named_table])
    {:ok, %{}}
  end

  def handle_call({:add_peer, info_hash, peer}, _from, state) do
    :peers |> :ets.insert({info_hash, peer})
    {:reply, :ok, state}
  end

  def handle_call(:all, _from, files) do
    {:reply, files}
  end

  def handle_call(:status, _from, files) do
    {:reply, "no of files getting downloading : #{length files}", files}
  end

end
