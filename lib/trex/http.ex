defmodule Trex.Http do
  
  def get(url, headers) do
    case :hackney.request(:get, url, headers, "",[]) do
      {:ok, _status, res_headers, client} -> body(client, res_headers)
      {:error, :nxdomain} -> raise "unknown host"
      {:error, :closed}  -> raise "could not connect to host"
    end

  end
   
  defp body(client, res_headers) do
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
