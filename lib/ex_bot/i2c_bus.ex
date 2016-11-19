defmodule ExBot.I2CBus do
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
  def read(i2c, channel) do
    {channel_value, _} = Integer.parse("#{channel + 40}", 16)
    i2c |> IO.inspect |> I2c.write(<<channel_value>>)
    i2c |> I2c.read(1)
    <<value>> = i2c |> I2c.read(1)
    value
  end
end
