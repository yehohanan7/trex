defmodule Trex.HTTP.Messages do
  alias Trex.BEncoding

  def parse_response(response) do
    {:dict, data} = response |> to_char_list |> BEncoding.decode
    %{"peers" => {:list, peers_list}, "interval" => interval} = data

    %{
      :peers    => Enum.map(peers_list, fn({:dict, %{"ip" => ip, "port" => port}}) -> {ip, port} end),
      :interval => interval
     }
  end


  def announce_request(info_hash, event) do
    params = %{"info_hash" => info_hash |> Hex.decode |> URI.encode,
               "peer_id"   => "ABCDEFGHIJKLMNOPQRST",
               "port"      => "7887",
               "uploaded"  => "0",
               "downloaded"=> "0",
               "left"      => "0",
               "ip"        => "0",
               "numwant"   => "100",
               "no_peer_id"=> "1",
               "event"     => event}
              |> 
              Enum.reduce(<<>>, fn ({key, value}, acc) -> acc <> "#{key}=#{value}&" end)
   "?" <> params
  end

end
