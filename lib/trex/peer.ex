defmodule Trex.Peer do
  @behaviour :gen_fsm
  alias Trex.Config, as: Config
  alias Trex.Torrent
  alias Trex.PeerSupervisor
  require IEx

  @time_out 0
  @next :timeout
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
      {:ok, sock} -> {:next_state, :initialized, %{host: host, port: port, sock: sock, tpid: tpid}, @time_out}
      {:error, _reason} -> {:stop, :shutdown, state}
    end
  end

  def initialized(@next, %{sock: sock, tpid: tpid} = state) do
    :ok = :gen_tcp.send(sock, @handshake_header)
    :ok = :gen_tcp.send(sock, Torrent.infohash(tpid) |> Hex.decode)
    :ok = :gen_tcp.send(sock, Config.peer_id)
    {:next_state, :handshake_initiated, state, @time_out}
  end

  def handshake_initiated(@next, %{sock: sock} = state) do
    case :gen_tcp.recv(sock, @handshake_response_size) do
      {:ok, <<19, "BitTorrent protocol", _::binary>>} -> {:next_state, :handshake_completed, state, @time_out}
      {:error, _reason} -> {:stop, :shutdown, state}
    end
  end

  def handshake_completed(@next, %{host: host, port: port, tpid: tpid, sock: sock} = state) do
    IO.inspect "handshake completed for #{host}:#{port}  hash: #{Torrent.infohash(tpid)}"
    keep_alive(state)
    {:next_state, :connected, state, @time_out}
  end

  def connected(@next, %{sock: sock} = state) do
    case :gen_tcp.recv(sock, 1) do
      {:ok, 0}    -> IO.inspect "keep alive recieved"
      {:ok, size} -> IO.inspect "other message recieved"
    end
    {:next_state, :connected, state, @time_out}
  end

  def handle_info(:keep_alive, statename, state) do
    keep_alive(state)
    {:next_state, statename, state}
  end

  def keep_alive(%{sock: sock} = state) do
    :gen_tcp.send(sock, <<0,0,0,0>>)
    :timer.send_after(6000, self(), :keep_alive)
  end

end
