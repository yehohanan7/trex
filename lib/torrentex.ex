defmodule Torrentex do
  use Application.Behaviour

  def version, do: 1.1

  def start(_type, options) do
    print_summary options
    Torrentex.Supervisor.start_link
  end

  def print_summary(options) do
    IO.puts "debug level : #{options[:log]}"
  end

  def start do
    start(:type, [])
  end

  #External APIs
  def download(file) do
    :gen_server.call :torrentex, {:download, file}
  end

  def status do
    :gen_server.call :torrentex, :status
  end

end
