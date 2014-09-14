defmodule Trex.PeerConnector do
  @behaviour :gen_fsm


  @handshake_header <<19::8, "BitTorrent protocol", 0::64>>
  @handshake_response_size 68

  @time_out 0
  
  def new(host, port, info_hash, peer_id, ppid) do
    state = %{} 
    |> Dict.put(:host, to_char_list(host))
    |> Dict.put(:port, port)
    |> Dict.put(:info_hash, info_hash)
    |> Dict.put(:peer_id, peer_id)
    |> Dict.put(:ppid, ppid)
    :gen_fsm.start_link(__MODULE__, state, [])
  end

  def send(pid, message) do
    
  end

  #GenServer Callbacks
  def terminate(_reason, _statename, _state) do
    :ok
  end

  def init(state), do: {:ok, :initialized, state, @time_out}


  def initialized(:timeout, %{host: host, port: port} = state) do
    case :gen_tcp.connect(host, port, [:binary, {:active, false}]) do
      {:ok, sock} -> {:next_state, :connected, Dict.put(state, :sock, sock), @time_out}
      {:error, _} -> IO.inspect "error while connecting..."; {:stop, :shutdown, state}
    end
  end

  def connected(:timeout, %{sock: sock, info_hash: info_hash, peer_id: peer_id} = state) do
    :ok = :gen_tcp.send(sock, @handshake_header)
    :ok = :gen_tcp.send(sock, info_hash |> Hex.decode)
    :ok = :gen_tcp.send(sock, peer_id)
    {:next_state, :handshake_initiated, state, @time_out}
  end

  def handshake_initiated(:timeout, %{sock: sock} = state) do
    case :gen_tcp.recv(sock, @handshake_response_size) do
      {:ok, <<19, "BitTorrent protocol", _::binary>>} -> {:next_state, :handshaked, Dict.put(state, :sock, sock), @time_out}
      {:error, _reason;} -> IO.inspect "error while handshaking"; {:stop, :shutdown, state}
    end
  end

  def handshaked(:timeout, state) do
    keep_alive(state);
    {:next_state, :active, state, @time_out}
  end

  def active(:timeout, %{ppid: ppid, sock: sock} = state) do
    case :gen_tcp.recv(sock, 1) do
      {:ok, 0}    -> :gen_fsm.send_event(ppid, "keep alive received")
      {:ok, size} -> :gen_fsm.send_event(ppid, "other message received")
    end
    {:next_state, :active, state, @time_out}
  end


  #keep alive handling
  def keep_alive(%{sock: sock} = state) do
    :gen_tcp.send(sock, <<0,0,0,0>>)
    :timer.send_after(6000, self(), :keep_alive)
  end

  def handle_info(:keep_alive, statename, state) do
    keep_alive(state)
    {:next_state, statename, state}
  end

end
