defmodule Onetime.Mixfile do
  use Mix.Project

  def project do
    [app: :onetime,
     version: "2.0.0",
     elixir: "~> 1.3",
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

  def application do
    [applications: [:logger, :timex, :tzdata]]
  end

  defp deps do
    [{:timex, "~> 3.0"},
     {:earmark, "~> 0.1", only: :dev},
     {:ex_doc, "~> 0.11", only: :dev}]
  end
end
