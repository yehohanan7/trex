defmodule Trex.Peer do
  @behaviour :gen_fsm

  #External API
  def start_link(torrent) do
    :gen_fsm.start_link(__MODULE__, torrent, [])
  end


  #GenFSM Callbacks
  def init(torrent) do
    IO.inspect "starting peer..."
    {:ok, :ready, torrent}
  end

  def terminate(_reason, _statename, _state) do
    :ok
  end

  #States
  def ready(event, torrent) do
    IO.inspect "peer ready!"
    {:next_state, :ready, torrent}
  end

  def ready(:peers, torrent) do
    IO.inspect "peers found!"
    {:next_state, :ready, torrent}
  end

  #Event handlers
  def handle_sync_event(:get_info_hash, _from, state_name, torrent) do
    {:reply, torrent[:info_hash], state_name, torrent}
  end



end
