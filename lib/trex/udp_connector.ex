defmodule Trex.UDPConnector do
  use GenServer

  #External API

  def new(remote_host, remote_port, handler_pid) do
    {:ok, pid} = :gen_server.start_link(__MODULE__, [to_char_list(remote_host), remote_port, handler_pid], [])
    pid
  end

  def send(pid, message) do
    :gen_server.call(pid, {:send, message})
  end

  def local_port(pid) do
    {:ok, port} = :gen_server.call(pid, :get_port)
    port
  end

  #GenServer Callbacks
  def init([remote_host, remote_port, handler]) do
    {:ok, socket} = :gen_udp.open(0, [:binary, {:active, true}])
    {:ok, %{socket: socket, remote_host: remote_host, remote_port: remote_port, handler: handler}}
  end

  def handle_call({:send, message}, _from, %{socket: socket, remote_host: remote_host, remote_port: remote_port} = state) do
    {:reply, :gen_udp.send(socket, remote_host, remote_port, message), state}
  end

  def handle_call(:get_port, _from, %{socket: socket} = state) do
    {:ok, port} =  :inet.port(socket)
    {:reply, {:ok, port}, state}
  end

  #Incoming messages from socket
  def handle_info({:udp, _, _ip, _port, packet}, %{:handler => handler} = state) do
    :gen_fsm.send_event(handler, packet)
    {:noreply, state}
  end

end
