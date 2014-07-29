defmodule Trex.HTTP.Messages do
  alias Trex.BEncoding
  require IEx

  defp parse_peers(data) do
    case data do
      <<>> -> []
      {:list, list} -> list
    end
  end

  def parse_response(response) do
    try do
      {:dict, %{"peers" => peers, "interval" => interval}} = response |> String.strip |> to_char_list |> BEncoding.decode
      %{
        :peers    => peers |> parse_peers |> Enum.map(fn({:dict, %{"ip" => ip, "port" => port}}) -> {ip, port} end),
        :interval => interval
      }
    rescue 
      e in UnicodeConversionError -> IEx.pry;raise "error parsing announce response"
    end
  end

  def announce_request_params(info_hash, event) do
    params = %{"info_hash" => info_hash |> Hex.decode |> URI.encode,
               "peer_id"   => "ABCDEFGHIJKLMNOPQRST",
               "port"      => "7887",
               "uploaded"  => "0",
               "ip"        => "0",
               "downloaded"=> "0",
               "left"      => "0",
               "compact"   => "1",
               "numwant"   => "200",
               "event"     => event}
              |> 
              Enum.reduce(<<>>, fn ({key, value}, acc) -> acc <> "#{key}=#{value}&" end)
   "?" <> params
  end

end
