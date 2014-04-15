defmodule Torrentex do
  use Application.Behaviour
  import IO

  def run(mode \\ :dev) do
    ~s(Starting "Torrentex" in #{mode} mode) |> puts
  end

  def version, do: 1.1

  # See http://elixir-lang.org/docs/stable/Application.Behaviour.html
  # for more information on OTP Applications
  def start(_type, _args) do
    Torrentex.Supervisor.start_link
  end

end
