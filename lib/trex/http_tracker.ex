defmodule Trex.HttpTracker do
  @behaviour :gen_fsm
  alias Trex.HTTP.Messages
  alias Trex.Torrent
  import IEx

  @time_out 0
  @retry_interval 10000

  @events %{:started => "started", :stopped => "stopped", :completed => "completed"}

  #External API
  def start_link(info_hash, url, torrent_pid) do
    :gen_fsm.start_link(__MODULE__, {info_hash, url, torrent_pid}, [])
  end

  #GenFSM Callbacks
  def init({info_hash, url, torrent_pid}) do
    {:ok, :initialized, %{info_hash: info_hash, url: url, torrent_pid: torrent_pid}, @time_out}
  end

  def terminate(_reason, _statename, state) do
    #announce(url, torrent[:info_hash], @events[:stopped]);
    :ok
  end

  #States
  def initialized(event, %{info_hash: info_hash, url: url} = state) do
    try do
       %{peers: peers, interval: interval} = announce(url, info_hash, @events[:started])
       Torrent.peers_found({:peers, peers})
       {:next_state, :initialized, Dict.put(state, :peers, peers), interval * 1000}
    rescue
      _ in _ -> IO.inspect "#{url} timed out, hence stopping.."; {:stop, "timeout", state}
    end
  end

  #Event handlers
  def handle_info(msg, state_name, state) do
    raise "uknown message recieved from #{state[:url]}"
  end

  #Private utility methods
  defp announce(url, info_hash, event) do
    Messages.announce_request_params(url, info_hash, event)
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
    Enum.find(res_headers, fn {key, value} -> key == "Content-Encoding" end)
  end

end
