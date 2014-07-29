defmodule Trex.UDPTracker do
  @behaviour :gen_fsm
  alias Trex.UDPConnector, as: Connector
  alias Trex.Peer
  import Trex.UDP.Messages

  @time_out 0

  #External API
  def start_link(id, {host, port}, torrent) do
    :gen_fsm.start_link({:local, id}, __MODULE__, {id, host, port, torrent}, [])
  end

  #GenFSM Callbacks
  def init({id, host, port, torrent}) do
    {:ok, :initialized, %{id: id, remote_tracker: {host, port}, torrent: torrent}, @time_out}
  end

  def terminate(_reason, _statename, _state) do
    :ok
  end

  #private utility methods
  def send(message, connector_pid, target) do
    case Connector.send(connector_pid, target, message) do
      {:error, reason} -> IO.inspect "error while sending request : #{reason}"
      _ -> :ok
    end
  end

  #States
  def initialized(event, state) do
    new_state = state
                |> Dict.put(:connector, Connector.new(0, self()))
                |> Dict.put(:transaction_id, :crypto.rand_bytes(4))
    {:next_state, :connector_ready, new_state, @time_out}
  end
  
  def connector_ready(_event, %{connector: {connector_pid, port}, remote_tracker: remote_tracker, transaction_id: transaction_id} = state) do
    connect_request(transaction_id) 
    |> send(connector_pid, remote_tracker)    
    {:next_state, :connecting, state}
  end
  
  def connecting(packet, state) do
    {:connection_id, connection_id} = parse_response(packet, state[:transaction_id])
    {:next_state, :connected, Dict.put(state, :connection_id, connection_id), @time_out}
  end

  def connected(_event, state) do
    IO.inspect "connected!!"
    {:next_state, :announcing, state, @time_out}
  end
  
  def announcing(_event, %{connector: {connector_pid, port}, connection_id: connection_id, transaction_id: transaction_id, torrent: torrent} = state) do
    announce_request(transaction_id, connection_id, torrent[:info_hash], port) 
    |> send(connector_pid, state[:remote_tracker])
    {:next_state, :announced, state}
  end

  def announced(packet, %{torrent: torrent} = state) do
    IO.inspect "announce response received"
    try do
      %{peers: peers, interval: interval} = parse_response(packet, state[:transaction_id])
      Peer.peers_found(torrent[:id], {:peers, peers})
      {:next_state, :announcing, state, interval * 1000}
    rescue 
      _ in _ -> IO.inspect "error parsing udp announce response..."; IO.inspect packet; {:next_state, :announcing, state, @time_out}
    end
  end

end

