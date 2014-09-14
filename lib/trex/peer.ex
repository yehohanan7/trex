defmodule Trex.Peer do
  @behaviour :gen_fsm
  alias Trex.Config, as: Config
  alias Trex.Torrent
  alias Trex.PeerSupervisor
  alias Trex.PeerConnector, as: Connector
  require IEx

  @time_out 0
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
  def init({host, 0, tpid}) do
    IO.inspect "invalid port"
    {:stop, :shutdown, %{}}
  end

  def init({host, port, tpid}) do
    {:ok, :initialized, %{host: host, port: port, tpid: tpid}, @time_out}
  end

  def initialized(:timeout, %{host: host, port: port, tpid: tpid} = state) do
    case Connector.new(host, port, Torrent.infohash(tpid), Config.peer_id, self()) do
      {:ok, connector} -> {:next_state, :connected, %{tpid: tpid, connector: connector}}
                    _  -> {:stop, :shutdown, %{}}
    end
  end

  def terminate(_reason, _statename, _state) do
    :ok
  end

  def connected(message, %{connector: connector, tpid: tpid} = state) do
    IO.inspect message
    {:next_state, :connected, state}
  end


end
