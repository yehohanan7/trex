defmodule Trex.Peer do
  @behaviour :gen_fsm
  alias Trex.Torrent
  alias Trex.PeerSupervisor

  @time_out 0

  #External API
  def start({host, port}, tpid) do
    PeerSupervisor.start_peer(host, port, tpid)
  end

  def start_link(host, port, tpid) do
    :gen_fsm.start_link(__MODULE__, {host, port, tpid}, [])
  end

  #GenServer Callbacks
  def init({host, port, tpid}) do
    {:ok, :initialized, %{host: host, port: port, tpid: tpid}, @time_out}
  end

  def terminate(_reason, _statename, _state) do
    :ok
  end

  def initialized(_event, %{host: host, port: port} = state) do
    IO.inspect "peer initialized for #{host} #{port}"
    {:next_state, :initialized, state}
  end

  def handle_info(_timeout, state) do
    {:noreply, state}
  end

end
