defmodule Kettle.Mixfile do
  use Mix.Project

  @target System.get_env("NERVES_TARGET") || "rpi3"

  def project do
    [app: :kettle,
     version: "0.1.0",
     target: @target,
     archives: [nerves_bootstrap: "~> 0.3.0"],
     kernel_modules: kernel_modules(@target),
     deps_path: "deps/#{@target}",
     build_path: "_build/#{@target}",
     
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps() ++ system(@target)]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Kettle, []},
     applications: [:logger, :nerves_interim_wifi, :nerves_network_interface, :httpotion]]
  end

  def deps do
    [{:nerves, "~> 0.5.1"},
     {:nerves_runtime, "~> 0.1.0"},
     {:nerves_interim_wifi, "~> 0.2.0"},
     {:nerves_network_interface, "~> 0.4.0"},
     {:httpotion, "~> 3.0.2"}]
  end

  def kernel_modules("rpi3") do
    ["brcmfmac"]
  end
  def kernel_modules(_), do: []

  def system(target) do
    [{:"nerves_system_#{target}", "~> 0.11.0", runtime: false}]
  end

  def aliases do
    ["deps.precompile": ["nerves.precompile", "deps.precompile"],
     "deps.loadpaths":  ["deps.loadpaths", "nerves.loadpaths"]]
  end

end
