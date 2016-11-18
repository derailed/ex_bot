defmodule Sensors.I2CBus do
  @moduledoc """
  I2CBus representation
  """

  @doc """
  Initialises a bus
  """
  def init(channel, address) do
    I2c.start_link("i2c-#{channel}", address)
  end

  @doc """
  Read data from the bus for the given channel
  """
  def read(bus, channel) do
    {channel_value, _} = Integer.parse("#{channel + 40}", 16)
    bus |> I2c.write(<<channel_value>>)
    bus |> I2c.read(1)
    <<value>> = bus |> I2c.read(1)
    value
  end
end
