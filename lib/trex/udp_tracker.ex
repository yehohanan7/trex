defmodule Trex.UDPTracker do
  @behaviour :gen_fsm
  alias Trex.Url
  alias Trex.UDPConnector, as: Connector
  alias Trex.Peer
  import Trex.Tracker.Messages


  #External API
  def start_link(id, port, url, torrent) do
    {tracker_host, tracker_port} = Url.parse(url)
    IO.inspect "staring udp tracker start_link"
    :gen_fsm.start_link({:local, id}, __MODULE__, {port, tracker_host, tracker_port, torrent}, [])
  end

  #GenFSM Callbacks
  def init({port, tracker_host, tracker_port, torrent}) do
    {:ok, :connector_ready, %{remote_tracker: {tracker_host, tracker_port}, torrent: torrent, connector: Connector.new(port, self())}, 0}
  end

  def terminate(_reason, _statename, _state) do
    :ok
  end

  #States
  def connector_ready(event, state) do
    transaction_id = generate_transaction_id

    transaction_id
    |> connect_request
    |> send(state[:remote_tracker], state[:connector])

    {:next_state, :awaiting_connection, Dict.put(state, :transaction_id, transaction_id)}
  end
  

  def awaiting_connection(packet, state) do
    {:connection_id, connection_id} = parse_response(packet, state[:transaction_id])
    {:next_state, :connected, Dict.put(state, :connection_id, connection_id), 0}
  end

  def connected(_event, %{torrent: torrent} = state) do
    IO.inspect "connected!!"
    :ok = Connector.send(state[:connector], state[:remote_tracker], announce_request(state[:transaction_id], state[:connection_id], torrent[:info_hash]))
    {:next_state, :announcing, state}
  end
  
  def announcing(packet, %{torrent: torrent} = state) do
    IO.inspect "announce response received"
    Peer.peers_found(torrent[:id], [:peer1, :peer2])
    {:next_state, :announced, state}
  end

  #Utilities
  defp generate_transaction_id do
    :crypto.rand_bytes(4)
  end

  defp send(message, {tracker, port}, connector) do
    :ok = Connector.send(connector, {tracker, port}, message)
  end


end
