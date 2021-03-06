defmodule Trex.Url do

  defp domain_port(url) do
    [host, _path] = String.split(url, "/")
    [domain, port] = cond do
      String.contains?(host, ":") -> String.split(host, ":")
      true -> [host, "80"]
    end
    {domain, String.to_integer(port)}
  end

  def parse_url(<<"udp://", path::binary>>) do
    domain_port(path)
  end

  def parse_url(<<"http://", path::binary>> = url), do: url

end
