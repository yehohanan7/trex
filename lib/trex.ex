defmodule Trex do
  use Application.Behaviour
  alias Trex.Server

  def version, do: 1.1

  def start(_type, options) do
    print_summary options
    Trex.Supervisor.start_link
  end

  def print_summary(options) do
    IO.puts "debug level : #{options[:log]}"
  end

  def start do
    start(:type, [])
  end

  #External APIs
  def download(file) do
    Server.download(file)
  end

  def status do
    Server.status
  end

end
