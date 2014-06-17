defmodule Trex.UDPTracker do
  @behaviour :gen_fsm
  alias Trex.Url
  alias Trex.UDPConnector, as: Connector
  alias Trex.Peer
  import Trex.Tracker.Messages

  @time_out 0

  #External API
  def start_link(id, port, url, torrent) do
    {tracker_host, tracker_port} = Url.parse(url)
    :gen_fsm.start_link({:local, id}, __MODULE__, {port, tracker_host, tracker_port, torrent}, [])
  end

  #GenFSM Callbacks
  def init({port, tracker_host, tracker_port, torrent}) do
    {:ok, :initialized, %{remote_tracker: {tracker_host, tracker_port}, torrent: torrent, port: port}, @time_out}
  end

  def terminate(_reason, _statename, _state) do
    :ok
  end

  #States
  def initialized(event, %{port: port} = state) do
    {:next_state, :connector_ready, Dict.put(state, :connector, Connector.new(port, self())), @time_out}
  end
  
  def connector_ready(_event, state) do
    transaction_id = :crypto.rand_bytes(4)
    :ok = Connector.send(state[:connector], state[:remote_tracker], connect_request(transaction_id))
    {:next_state, :awaiting_connection, Dict.put(state, :transaction_id, transaction_id)}
  end
  
  def awaiting_connection(packet, state) do
    {:connection_id, connection_id} = parse_response(packet, state[:transaction_id])
    {:next_state, :connected, Dict.put(state, :connection_id, connection_id), @time_out}
  end

  def connected(_event, %{torrent: torrent, transaction_id: transaction_id, connection_id: connection_id} = state) do
    IO.inspect "connected!!"
    :ok = Connector.send(state[:connector], state[:remote_tracker], announce_request(transaction_id, connection_id, torrent[:info_hash]))
    {:next_state, :announcing, state}
  end
  
  def announcing(packet, state) do
    IO.inspect "announce response received"
    {:next_state, :peers_determined, state, @time_out}
  end

  def peers_determined(_, %{torrent: torrent} = state) do
    IO.inspect "remote peers publishing to local peer...."
    Peer.peers_found(torrent[:id], [:peer1, :peer2])
    {:next_state, :peers_determined, state}
  end

end
