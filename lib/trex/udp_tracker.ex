defmodule Trex.UDPTracker do
  @behaviour :gen_fsm
  alias Trex.Url
  alias Trex.UDPConnector, as: Connector
  alias Trex.Tracker.Messages, as: Messages


  #External API
  def start_link(port, torrent) do
    :gen_fsm.start_link(__MODULE__, [port, torrent], [])
  end

  defp message_handler (pid) do
    fn packet ->
         :gen_fsm.send_event(pid, packet)
    end
  end

  #GenFSM Callbacks
  def init([port, torrent]) do
    {:ok, connector} = Connector.new(port, message_handler(self()))
    {:ok, :connector_ready, %{torrent: torrent, connector: connector}, 0}
  end

  def terminate(_reason, _statename, _state) do
    :ok
  end


  #States
  def connector_ready(event, %{torrent: torrent, connector: connector} = state) do
    transaction_id = generate_transaction_id

    transaction_id
    |> Messages.connect_request
    |> send(Url.host(torrent[:announce]), connector)
    
    {:next_state, :connecting, Dict.put(state, :transaction_id, transaction_id)}
  end
  

  def connecting(packet, %{connector: connector, torrent: torrent, transaction_id: transaction_id} = state) do
    IO.inspect "connected!"    
    {connection_id: connection_id} = Messages.parse(packet, transaction_id)
    :ok = Connector.send(connector, Url.host(torrent[:announce]), Messages.announce_request(state[:transaction_id], connection_id))
    {:next_state, :announcing, Dict.put(state, :connector_id, connection_id)}
  end
  
  def announcing(packet, state) do
    IO.inspect "announce response received"
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
