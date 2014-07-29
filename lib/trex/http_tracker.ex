defmodule Trex.HttpTracker do
  @behaviour :gen_fsm
  alias Trex.HTTP.Messages
  alias Trex.Peer

  @time_out 0
  @events %{:started => "started", :stopped => "stopped", :completed => "completed"}

  #External API
  def start_link(id, url, torrent) do
    :gen_fsm.start_link({:local, id}, __MODULE__, {id, url, torrent}, [])
  end
  
  #Private utility methods
  defp http_get(request, url) do
    %HTTPotion.Response{body: body} = HTTPotion.get(url <> request);body
  end

  defp announce(url, info_hash, event) do
    Messages.announce_request_params(info_hash, event)
    |> http_get(url)
    |> Messages.parse_response
  end

  #GenFSM Callbacks
  def init({id, url, torrent}) do
    {:ok, :initialized, %{id: id, url: url, torrent: torrent}, @time_out}
  end

  def terminate(_reason, _statename, %{url: url, torrent: torrent}) do
    announce(url, torrent[:info_hash], @events[:stopped]);:ok
  end

  #States
  def initialized(event, %{url: url, torrent: torrent} = state) do
    try do
      %{peers: peers, interval: interval} = announce(url, torrent[:info_hash], @events[:started])
      Peer.peers_found(torrent[:id], {:peers, peers})
      {:next_state, :initialized, Dict.put(state, :peers, peers), interval * 1000}
    rescue 
      e in _ -> IO.inspect "error contacting #{url}";IO.inspect e; {:stop, "error in tracker #{url}", state}
    end
  end

  #Event handlers
  def handle_event(_event, state_name, state) do
    IO.inspect "peers:::";IO.inspect state[:peers]
  end

  def handle_info(msg, state_name, state) do
    IO.inspect "unknown message received";IO.inspect msg
    {:next_state, state_name, state}
  end

end
