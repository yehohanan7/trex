defmodule Trex.UDPTracker do
  @behaviour :gen_fsm
  alias Trex.UDPConnector, as: Connector
  alias Trex.Torrent
  import Trex.Url
  import Trex.UDP.Messages

  @time_out 0

  #External API
  def start_link(url, tpid) do
    :gen_fsm.start_link(__MODULE__, {parse_url(url), tpid}, [])
  end

  #GenFSM Callbacks
  def init({{host, port}, tpid}) do
    {:ok, :initialized, %{remote_tracker: {host, port}, tpid: tpid}, @time_out}
  end

  def terminate(_reason, _statename, _state) do
    :ok
  end

  #private utility methods
  def send_message(message, connector) do
    case Connector.send(connector, message) do
      {:error, reason} -> IO.inspect "error while sending request : #{reason}"
      _ -> :ok
    end
  end

  #States
  def initialized(_event, %{remote_tracker: {host, port}} = state) do
    {:next_state, :connector_ready, Dict.put(state, :connector, Connector.new(host, port, self())), @time_out}
  end

  def connector_ready(_event, state) do
    {:next_state, :transaction_ready, Dict.put(state, :transaction_id, :crypto.rand_bytes(4)), @time_out}
  end

  def transaction_ready(_event, %{connector: connector, transaction_id: transaction_id} = state) do
    connect_request(transaction_id) |> send_message(connector)    
    {:next_state, :awaiting_connection, state}
  end

  
  def awaiting_connection(packet, state) do
    {:connection_id, connection_id} = parse_response(packet, state[:transaction_id])
    {:next_state, :connected, Dict.put(state, :connection_id, connection_id), @time_out}
  end

  def connected(_event, state) do
    IO.inspect "connected!!"
    {:next_state, :announcing, state, @time_out}
  end
  
  def announcing(_event, %{connector: connector, connection_id: connection_id, transaction_id: transaction_id, tpid: tpid} = state) do
    announce_request(transaction_id, connection_id, Torrent.infohash(tpid), Connector.local_port(connector)) 
    |> send_message(connector)
    {:next_state, :announced, state}
  end

  def announced(packet, %{tpid: tpid} = state) do

    case parse_response(packet, state[:transaction_id]) do

      %{peers: peers, interval: interval} -> 
        Torrent.update_peers(tpid, {:peers, peers})
        {:next_state, :announcing, state, interval * 1000}

       _ -> {:next_state, :initialized, state, @time_out}

    end
  end

end

