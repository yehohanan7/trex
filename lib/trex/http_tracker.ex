defmodule Trex.HttpTracker do
  use GenServer
  alias Trex.HTTP.Messages
  alias Trex.Torrent
  alias Trex.Http

  @time_out 0

  @events %{:started => "started", :stopped => "stopped", :completed => "completed"}

  #External API
  def start_link(url, tpid) do
    GenServer.start_link(__MODULE__, {url, tpid})
  end

  #GenServer Callbacks
  def init({url, tpid}) do
    {:ok, %{url: url, tpid: tpid}, @time_out}
  end

  def terminate(_reason, _state) do
    :ok
  end

  def handle_info(_timeout, %{url: url, tpid: tpid} = state) do
    try do
      %{peers: peers, interval: interval} = Torrent.infohash(tpid)
      |> Messages.announce_request(url, @events[:started])
      |> Http.get([{"User-Agent", "Trex"}])
      |> Messages.parse_response

      Torrent.update_peers(tpid, {:peers, peers})
      {:noreply, Dict.put(state, :peers, peers), interval * 1000}
    rescue
      e in _ -> {:stop, "error while fetching peers from #{url}", state}
    end
  end

end
