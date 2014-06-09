defmodule Trex.Mixfile do
  use Mix.Project

  def project do
    [ app: :trex,
      version: "0.0.1",
      elixir: "~> 0.13.2",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [mod: { Trex, log: :verbose}]
  end

  # Returns the list of dependencies in the format:
  # { :foobar, git: "https://github.com/elixir-lang/foobar.git", tag: "0.1" }
  #
  # To specify particular versions, regardless of the tag, do:
  # { :barbat, "~> 0.1", github: "elixir-lang/barbat" }
  defp deps do
    [{:hex, github: "rjsamson/hex"},
     {:httpotion, github: "myfreeweb/httpotion"},
     {:exlager, github: "khia/exlager"}]
  end
end
