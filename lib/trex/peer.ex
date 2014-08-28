defmodule Trex.Peer do
  @behaviour :gen_fsm
  alias Trex.BEncoding
  alias Trex.Torrent
  alias Trex.PeerSupervisor

  @time_out 0

  @next :timeout

  @peer_id 1234
  @handshake_header <<19::8, "BitTorrent protocol", 0::64>>
  @handshake_response_size 68

  #External API
  def start({host, port}, tpid) do
    PeerSupervisor.start_peer(host, port, tpid)
  end

  def start_link(host, port, tpid) do
    :gen_fsm.start_link(__MODULE__, {host, port, tpid}, [])
  end

  #GenServer Callbacks
  def init({host, port, tpid}) do
    {:ok, :initializing, %{host: host, port: port, tpid: tpid}, @time_out}
  end

  def terminate(_reason, _statename, _state) do
    :ok
  end

  def initializing(@next, %{port: 0} = state) do
    IO.inspect "invalid port"
    {:stop, :shutdown, state}
  end

  def initializing(@next, %{host: host, port: port, tpid: tpid} = state) do
    case :gen_tcp.connect(to_char_list(host), port, [:binary, {:active, false}]) do
      {:ok, sock} -> {:next_state, :initialized, %{sock: sock, tpid: tpid}, @time_out}
      {:error, reason} -> IO.inspect "error while connecting to peer... #{host}:#{port}"; {:stop, :shutdown, state}
    end
  end

  def initialized(@next, %{sock: sock, tpid: tpid} = state) do
    :ok = :gen_tcp.send(sock, @handshake_header)
    :ok = :gen_tcp.send(sock, Torrent.infohash(tpid) |> Hex.decode)
    :ok = :gen_tcp.send(sock, <<@peer_id::160>>)
    {:next_state, :handshake_initiated, state, @time_out}
  end

  def handshake_initiated(event, %{sock: sock} = state) do
    case :gen_tcp.recv(sock, @handshake_response_size) do
      {:ok, data}      -> IO.inspect "hand shake response recieved.."
                          data |> BEncoding.decode |> IO.inspect
                          {:next_state, :handshake_completed, state}

      {:error, reason} -> IO.inspect "error while handshaking.."; {:stop, :shutdown, state}
    end
  end

  def handle_info(msg, statename, state) do
    IO.inspect "unknown message... #{statename}"
    {:stop, :shutdown, state}
  end

end
