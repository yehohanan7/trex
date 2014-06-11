defmodule Trex do
  use Application.Behaviour
  alias Trex.Supervisor

  def version, do: 1.1

  def start(_type, options) do
    IO.puts "Starting Trex..."
    Supervisor.start_link
  end

  def start do
    start(:type, [])
  end

  #External APIs
  def download(file) do
    Supervisor.start_download(file)
  end

  def status do
    "Not yet implemented"
  end

end
