defmodule Trex.Peer do
  @behaviour :gen_fsm
  
  @timeout 0

  #External API
  def start_link(id, torrent) do
    :gen_fsm.start_link({:local, id}, __MODULE__, torrent, [])
  end

  def peers_found(id, peers) do
    :gen_fsm.send_event(id, {:peers, peers})
  end


  #GenFSM Callbacks
  def init(torrent) do
    IO.inspect "starting peer..."
    {:ok, :initialized, torrent, @timeout}
  end

  def terminate(_reason, _statename, _state) do
    :ok
  end

  #States

  def initialized(_event, torrent) do
    IO.inspect "peer ready"
    {:next_state, :ready, torrent}
  end

  def ready({:peers, peers}, torrent) do
    IO.inspect peers
    {:next_state, :ready, torrent}
  end


end
