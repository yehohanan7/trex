defmodule Trex.HttpTracker do
  @behaviour :gen_fsm
  @time_out 0

  #External API
  def start_link(id, url, torrent) do
    {host, port} = Url.parse(url)
    :gen_fsm.start_link({:local, id}, __MODULE__, {host, port, torrent}, [])
  end

  #GenFSM Callbacks
  def init({host, port, torrent}) do
    {:ok, :initialized, %{remote_tracker: {host, port}}, @time_out}
  end

  def terminate(_reason, _statename, _state) do
    :ok
  end

  #States
  def initialized(event, state) do
    {:next_state, :connector_ready, Dict.put(state, :connector, Connector.new(0, self())), @time_out}
  end
  
  def connector_ready(_event, state) do
  end
  
  def awaiting_connection(packet, state) do

  end

  def connected(_event, %{torrent: torrent, transaction_id: transaction_id, connection_id: connection_id} = state) do

  end
  
  def announcing(packet, state) do

  end

  def peers_determined(packet, %{torrent: torrent} = state) do

  end


  #Utils
  def send({connector_pid, _}, target, request) do

    case Connector.send(connector_pid, target, request) do
      {:error, reason} -> IO.inspect "error while sending request : #{reason}"
      _ -> :ok
    end
    
  end


end
