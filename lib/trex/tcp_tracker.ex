defmodule Trex.TCPTracker do

  #External API
  def start_link(port, torrent) do
    :gen_server.start_link(__MODULE__, [port, torrent], [])
  end

  #GenServer Callbacks
  def init([port, torrent]) do
    IO.inspect "starting a tcp tracker for #{torrent[:announce]}"
    {:ok, %{}, 0}
  end


  def handle_info(:timeout, state) do
    IO.inspect "sending tcp connect request"
    {:noreply, state}
  end

end
