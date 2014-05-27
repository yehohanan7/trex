defmodule Torrentex.UDPTracker do
  @behaviour :gen_fsm
  alias Torrentex.Url

  @actions %{:connect   => 0,
             :announce  => 1,
             :scrape    => 2,
             :error     => 3}

  @connection_timeout 500

  #External API
  def start_link(port, torrent) do
    :gen_fsm.start_link(__MODULE__, [port, torrent], [])
  end

  #GenServer Callbacks
  def init([port, torrent]) do
    {:ok, socket} = :gen_udp.open(port, [:binary, {:active, true}])
    {:ok, :initialized, %{:socket => socket, :torrent => torrent}, 0}
  end

  def terminate(_reason, _statename, _state) do
    :ok
  end

  #States
  def initialized(event, %{:socket => socket, :torrent => torrent} = state) do
    [domain, port] = Url.host(torrent[:announce])
    :ok = :gen_udp.send(socket, domain, port, <<4497486125440::64,@actions[:connect]::32, generate_transaction_id::binary>>)
    {:next_state, :connecting, state}
  end
  

  #Socket message handlers
  def packet_recieved(:connecting, packet, state) do
    IO.inspect "conected!!!"
    IO.inspect "-------------------"
    IO.inspect packet
    IO.inspect "-------------------"
    {:next_state, :connected, state}
  end

  def packet_recieved(:connected, packet, state) do
    {:next_state, :connected, state}
  end


  #Incoming messages from socket
  def handle_info({:udp, _, _ip, _port, packet}, state_name, state) do
    packet_recieved(state_name, packet, state)
  end

  #Utilities
  defp generate_transaction_id do
    :crypto.rand_bytes(4)
  end

end
