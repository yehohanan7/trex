defmodule Trex.Peer do
  use GenServer
  alias Trex.Torrent
  alias Trex.PeerSupervisor

  #External API
  def start({host, port}, tpid) do
    PeerSupervisor.start_peer(host, port, tpid)
  end

  def start_link(host, port, tpid) do
    GenServer.start_link(__MODULE__, {host, port, tpid})
  end

  #GenServer Callbacks
  def init({host, port, tpid}) do
    IO.inspect "peer started for #{host} #{port}"
    {:ok, %{host: host, port: port, tpid: tpid}}
  end

  def terminate(_reason, _state) do
    :ok
  end

  def handle_info(_timeout, state) do
    {:noreply, state}
  end

end
