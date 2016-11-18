defmodule Sensors.Gpio do
  @moduledoc """
  Manages GPIO devices
  """

  @doc """
  Initializes pin and direction
  """
  def init(pin, direction) when direction in [:input, :output] do
    Gpio.start_link(pin, direction)
  end

  @doc """
  Toggle device state on or off
  """
  def toggle(device, :on) do
    device |> Gpio.write(0)
  end
  def toggle(device, :off) do
    device |> Gpio.write(1)
  end

  def read(device) do
    device |> Gpio.read()
  end
end