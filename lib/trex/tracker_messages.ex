defmodule Trex.Tracker.Messages do


  @actions %{:connect   => 0,
             :announce  => 1,
             :scrape    => 2,
             :error     => 3}


  def connect_request(transaction_id) do
    <<4497486125440::64,@actions[:connect]::32, transaction_id::binary>>
  end

  def announce_request(transaction_id, connection_id, torrent) do
    <<connection_id::[size(8), binary], @actions[:announce]::32, transaction_id::[size(4), binary], torrent[:info_hash]::[size(20), binary], 1::160,0::64, 0::64, 0::64, 0::32, 0::32, 0::32, -1::32, 9998::16>>
  end
  
  def parse_response(packet, transaction_id) do
    
    case packet do
      <<0::32, transaction_id::[size(4), binary], connection_id::binary>> -> 
        {connection_id: connection_id}
      _ -> 
        :error
    end

  end

end
