defmodule Trex.HttpTracker do
  @behaviour :gen_fsm
  alias Trex.HTTP.Messages
  alias Trex.Torrent
  import IEx

  @time_out 0

  @events %{:started => "started", :stopped => "stopped", :completed => "completed"}

  #External API
  def start_link(url, tpid) do
    :gen_fsm.start_link(__MODULE__, {url, tpid}, [])
  end

  #GenFSM Callbacks
  def init({url, tpid}) do
    {:ok, :getting_peers, %{url: url, tpid: tpid}, @time_out}
  end

  def terminate(_reason, _statename, _state) do
    #announce(url, torrent[:info_hash], @events[:stopped]);
    :ok
  end

  #States
  def getting_peers(event, %{url: url, tpid: tpid} = state) do
    try do
       %{peers: peers, interval: interval} = announce(url, Torrent.infohash(tpid), @events[:started])
       Torrent.peers_found(tpid, {:peers, peers})
       {:next_state, :getting_peers, Dict.put(state, :peers, peers), interval * 1000}
    rescue
      _ in _ -> IO.inspect "#{url} timed out, hence stopping.."; {:stop, "timeout", state}
    end
  end

  #Event handlers
  def handle_info(_msg, _state_name, state) do
    raise "uknown message recieved from #{state[:url]}"
  end

  #Private utility methods
  defp announce(url, info_hash, event) do
    Messages.announce_request(url, info_hash, event)
    |> http_get([{"User-Agent", "Trex"}])
    |> Messages.parse_response
  end

  defp http_get(url, headers) do
    {:ok, _status, res_headers, client} = :hackney.request(:get, url, headers, "",[])
    {:ok, body} = :hackney.body(client)    
    case content_encoding(res_headers) do
      {_, "gzip"} -> :zlib.gunzip body
      _           -> body
    end
  end

  defp content_encoding(res_headers) do
    Enum.find(res_headers, fn {key, _} -> key == "Content-Encoding" end)
  end

end
