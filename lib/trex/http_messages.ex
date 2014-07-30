defmodule Trex.HTTP.Messages do
  alias Trex.BEncoding
  require IEx

  @default_interval 200

  defp parse_peers(data) do
    case data do
      <<>> -> []
      {:list, list} -> list
    end
  end

  def to_map(data) do
    {:dict, %{"peers" => peers, "interval" => interval}} = data |> to_char_list |> BEncoding.decode
    %{
      :peers    => peers |> parse_peers |> Enum.map(fn({:dict, %{"ip" => ip, "port" => port}}) -> {ip, port} end),
      :interval => interval
    }
  end

  def parse_response(data) do
    response = data |> String.strip 
    cond do
      String.valid_character?(response) -> to_map(response)
      true                              -> IO.inspect "invalid string! "; IO.inspect response;%{peers: [], interval: @default_interval}
    end
  end

  def announce_request_params(info_hash, event) do
    IO.inspect(info_hash)
    params = %{"info_hash" => info_hash |> Hex.decode |> URI.encode,
               "peer_id"   => "ABCDEFGHIJKLMNOPQRST",
               "port"      => "7887",
               "uploaded"  => "0",
               "downloaded"=> "0",
               "left"      => "0",
               "ip"        => "0",
               "numwant"   => "200",
               "no_peer_id"=> "1",
               #"compact"   => "1",
               "event"     => event}
              |> 
              Enum.reduce(<<>>, fn ({key, value}, acc) -> acc <> "#{key}=#{value}&" end)
   "?" <> params
  end

end
