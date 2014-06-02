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
    transaction_id = generate_transaction_id
    IO.inspect transaction_id
    :ok = :gen_udp.send(socket, domain, port, <<4497486125440::64,@actions[:connect]::32, transaction_id::binary>>)
    {:next_state, :connecting, Dict.put(state, :transaction_id, transaction_id)}
  end
  

  #Socket message handlers
  def packet_recieved(:connecting, packet, state) do
    transaction_id = state[:transaction_id]
    case packet do
      <<0::32, transaction_id::[size(4), binary], connection_id::binary>> -> 
        IO.inspect "connected!"
        {:next_state, :connected, Dict.put(state, :connection_id, connection_id)}
      _ -> 
        {:stop, "Invalid packet recieved while connecting", %{}}
    end
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
