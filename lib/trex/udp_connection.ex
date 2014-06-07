defmodule Trex.UDPConnection do
  use GenServer.Behaviour

  #External API

  def new(port, handler) do
    IO.inspect "new connection.."
    :gen_server.start_link(__MODULE__, [port, handler], [])
  end

  def send(pid, [host, port], message) do
    :gen_server.cast(pid, %{target: [host, port], message: message})
  end


  #GenServer Callbacks
  def init([port, handler]) do
    IO.inspect "initing connection.."
    {:ok, socket} = :gen_udp.open(port, [:binary, {:active, true}])
    {:ok, %{:socket => socket, :handler => handler}}
  end

  def handle_cast(%{target: [host, port], message: message}, %{socket: socket} = state) do
    IO.inspect "SENDING PACKET"
    :ok = :gen_udp.send(socket, host, port, message)
    {:noreply, state}
  end

  #Incoming messages from socket
  def handle_info({:udp, _, _ip, _port, packet}, %{:handler => handler} = state) do
    handler.(packet)
    {:noreply, state}
  end

end
