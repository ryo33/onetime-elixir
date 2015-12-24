defmodule Onetime.Mixfile do
  use Mix.Project

  def project do
    [app: :onetime,
     version: "0.1.2",
     elixir: "~> 1.1",
     description: "An onetime key-value store",
     package: [
       maintainers: ["Ryo Hashiguchi(ryo33)"],
       licenses: ["MIT"],
       links: %{"GitHub" => "https://github.com/ryo33/onetime-elixir"}
     ],
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:timex, "~> 1.0.0-rc4"},
     {:earmark, "~> 0.1", only: :dev},
     {:ex_doc, "~> 0.11", only: :dev}]
  end
end
