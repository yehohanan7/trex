defmodule Trex.UDPTracker do
  @behaviour :gen_fsm
  alias Trex.Url
  alias Trex.UDPConnector, as: Connector
  import Trex.Tracker.Messages


  #External API
  def start_link(port, torrent) do
    :gen_fsm.start_link(__MODULE__, [port, torrent], [])
  end

  #GenFSM Callbacks
  def init([port, torrent]) do
    {:ok, :connector_ready, %{torrent: torrent, connector: Connector.new(port, self())}, 0}
  end

  def terminate(_reason, _statename, _state) do
    :ok
  end


  #States
  def connector_ready(event, state) do
    transaction_id = generate_transaction_id

    transaction_id
    |> connect_request
    |> send(Url.host(state[:torrent][:announce]), state[:connector])

    {:next_state, :awaiting_connection, Dict.put(state, :transaction_id, transaction_id)}
  end
  

  def awaiting_connection(packet, state) do
    {connection_id: connection_id} = parse_response(packet, state[:transaction_id])
    {:next_state, :connected, Dict.put(state, :connection_id, connection_id), 0}
  end

  def connected(_, state) do
    IO.inspect "connected!!"
    :ok = Connector.send(state[:connector], Url.host(state[:torrent][:announce]), announce_request(state[:transaction_id], state[:connection_id]))
    {:next_state, :announcing, state}
  end
  
  def announcing(packet, state) do
    IO.inspect "announce response received"
    IO.inspect packet
    {:reply, :connected, :connected, state}
  end

  #Utilities
  defp generate_transaction_id do
    :crypto.rand_bytes(4)
  end

  defp send(message, target, connector) do
    :ok = Connector.send(connector, target, message)
  end


end
