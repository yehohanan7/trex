defmodule Trex.UDPTracker do
  @behaviour :gen_fsm
  alias Trex.Url
  alias Trex.UDPConnector, as: Connector
  import Trex.Tracker.Messages


  #External API
  def start_link(port, tracker_host, tracker_port, peer) do
    :gen_fsm.start_link(__MODULE__, {port, tracker_host, tracker_port, peer}, [])
  end

  #GenFSM Callbacks
  def init({port, tracker_host, tracker_port, peer}) do
    {:ok, :connector_ready, %{target_tracker: {tracker_host, tracker_port}, peer: peer, connector: Connector.new(port, self())}, 0}
  end

  def terminate(_reason, _statename, _state) do
    :ok
  end

  #States
  def connector_ready(event, state) do
    transaction_id = generate_transaction_id

    transaction_id
    |> connect_request
    |> send(state[:target_tracker], state[:connector])

    {:next_state, :awaiting_connection, Dict.put(state, :transaction_id, transaction_id)}
  end
  

  def awaiting_connection(packet, state) do
    {connection_id: connection_id} = parse_response(packet, state[:transaction_id])
    {:next_state, :connected, Dict.put(state, :connection_id, connection_id), 0}
  end

  def connected(_event, %{peer: peer} = state) do
    IO.inspect "connected!!"
    info_hash = :gen_fsm.sync_send_all_state_event(peer, :get_info_hash)
    :ok = Connector.send(state[:connector], state[:target_tracker], announce_request(state[:transaction_id], state[:connection_id], info_hash))
    {:next_state, :announcing, state}
  end
  
  def announcing(packet, %{peer: peer, transaction_id: transaction_id} = state) do
    IO.inspect "announce response received"
    IO.inspect(parse_response(packet, transaction_id))
    :gen_fsm.send_event(peer, :peers)
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
