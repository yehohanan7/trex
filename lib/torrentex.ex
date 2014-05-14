defmodule Torrentex do
  use Application.Behaviour
  import IO

  def version, do: 1.1

  # See http://elixir-lang.org/docs/stable/Application.Behaviour.html
  # for more information on OTP Applications
  def start(_type, _args) do
    Torrentex.Supervisor.start_link
  end

  def start do
    start(:type, [])
  end

  #External APIs
  def download(file) do
    :gen_server.call :torrentex, {:download, file}
  end

  def status(file) do
    :gen_server.call :torrentex, {:status, file}
  end

  def pending do
    :gen_server.call :torrentex, :pending
  end

end
