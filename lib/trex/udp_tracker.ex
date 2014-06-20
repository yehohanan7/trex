defmodule Trex.UDPTracker do
  @behaviour :gen_fsm
  alias Trex.Url
  alias Trex.UDPConnector, as: Connector
  alias Trex.Peer
  import Trex.Tracker.Messages

  @time_out 0

  #External API
  def start_link(id, url, torrent) do
    {host, port} = Url.parse(url)
    :gen_fsm.start_link({:local, id}, __MODULE__, {host, port, torrent}, [])
  end

  #GenFSM Callbacks
  def init({host, port, torrent}) do
    {:ok, :initialized, %{remote_tracker: {host, port}, torrent: torrent}, @time_out}
  end

  def terminate(_reason, _statename, _state) do
    :ok
  end

  #States
  def initialized(event, state) do
    {:next_state, :connector_ready, Dict.put(state, :connector, Connector.new(0, self())), @time_out}
  end
  
  def connector_ready(_event, state) do
    transaction_id = :crypto.rand_bytes(4)
    case Connector.send(state[:connector], state[:remote_tracker], connect_request(transaction_id)) do
      {:error, reason} -> IO.inspect "error while sending connect request : #{reason}"
      _ -> :ok
    end
    {:next_state, :awaiting_connection, Dict.put(state, :transaction_id, transaction_id)}
  end
  
  def awaiting_connection(packet, state) do
    {:connection_id, connection_id} = parse_response(packet, state[:transaction_id])
    {:next_state, :connected, Dict.put(state, :connection_id, connection_id), @time_out}
  end

  def connected(_event, %{torrent: torrent, transaction_id: transaction_id, connection_id: connection_id} = state) do
    IO.inspect "connected!!"
    case Connector.send(state[:connector], state[:remote_tracker], announce_request(transaction_id, connection_id, torrent[:info_hash])) do
      {:error, reason} -> IO.inspect "error while sending announce request : #{reason}"
      _ -> :ok
    end
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
