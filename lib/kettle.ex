defmodule Kettle do
  use Application

  require Logger

  @ledpin Application.get_env(:hello_gpio, :ledpin)[:pin]

  @interface :wlan0
  @kernel_modules Mix.Project.config[:kernel_modules] || []

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    # Define workers and child supervisors to be supervised
    {:ok, pin} = Gpio.start_link(@ledpin, :output)

    children = [
      worker(Task, [fn -> init_kernel_modules() end], restart: :transient, id: Nerves.Init.KernelModules),
      worker(Task, [fn -> init_network() end], restart: :transient, id: Nerves.Init.Network),
      worker(Task, [fn -> blink_led_forever(pin) end])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Kettle.Supervisor]
    Supervisor.start_link(children, opts)

    {:ok, self()}
  end

  def init_kernel_modules() do
    Enum.each(@kernel_modules, & System.cmd("modprobe", [&1]))
  end

  def init_network() do
    Nerves.InterimWiFi.setup @interface, ssid: "calwifi_slow", key_mgmt: :"WPA-PSK", psk: "calhinshaw"
  end

  defp blink_led_forever(pin) do
    Gpio.write(pin, 1)
    :timer.sleep(500)
    Gpio.write(pin, 0)
    :timer.sleep(500)

    blink_led_forever(pin)
  end

end
