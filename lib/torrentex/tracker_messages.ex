defmodule Torrentex.Tracker.Messages do


  @actions %{:connect   => 0,
             :announce  => 1,
             :scrape    => 2,
             :error     => 3}


  def connect_request(transaction_id) do
    <<4497486125440::64,@actions[:connect]::32, transaction_id::binary>>
  end

  def announce_request(transaction_id, connection_id) do
    <<connection_id::[size(8), binary], @actions[:announce]::32, transaction_id::[size(4), binary]>>
  end
  
  def parse(packet, transaction_id) do
    
    case packet do
      <<0::32, transaction_id::[size(4), binary], connection_id::binary>> -> 
        {connection_id: connection_id}
      _ -> 
        :error
    end

  end

end
