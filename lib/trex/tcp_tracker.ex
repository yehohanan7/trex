defmodule Trex.TCPTracker do

  #External API
  def start_link(port, url, info_hash) do
    :gen_server.start_link(__MODULE__, {port, "", ""}, [])
  end

  #GenServer Callbacks
  def init({port, tracker_host, tracker_port}) do
    IO.inspect "starting a tcp tracker..."
    {:ok, %{}, 0}
  end


  def handle_info(:timeout, state) do
    IO.inspect "sending tcp connect request"
    {:noreply, state}
  end

end
