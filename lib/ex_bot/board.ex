defmodule ExBot.Board do
  @moduledoc """
  Virtual representation of an IOT installation
  """

  defstruct [:gpios, :i2c, :i2c_bus, :socket, :conn]

  alias ExBot.{I2CBus, Gpio}

  def init do
    bus_config = Application.fetch_env(:ex_bot, :i2c)
    {i2c, i2c_devs} = case bus_config do
      {:ok, c} -> { I2CBus.init(c[:channel], c[:address]), c[:bus] }
      :error   -> { nil, [] }
    end

    {:ok, gpios} = case Application.fetch_env(:ex_bot, :gpios) do
      {:ok, devices} ->
        { :ok,
          for d <- devices do
            case Gpio.init(d[:pin], d[:direction]) do
              {:ok, dev} -> [device: dev, config: d]
              :error     -> raise "Unable to initialize pin `#{d[:pin]}"
            end
          end
        }
      :error -> {:ok, []}
    end

    %ExBot.Board{
      i2c:     i2c,
      i2c_bus: i2c_devs,
      gpios:   gpios,
      conn:    self
    }
  end

  def toggle(board, name, state) do
    d = board
    |> locate(:gpio, name)
    d[:device] |> Gpio.toggle(state)
    board
  end

  def read(board, :i2c, name) do
    dev = board
    |> locate(:i2c, name)
    |> IO.inspect
    board.i2c |> IO.inspect |> I2CBus.read(dev[:channel])
  end
  def read(board, :gpio, name) do
    dev = board |> locate(:gpio, name)
    dev[:device] |> Gpio.read
  end

  defp locate(board, :gpio, name) do
    board.gpios
    |> Enum.filter(&(&1[:config][:name] == name))
    |> List.first
  end
  defp locate(board, :i2c, name) do
    board.i2c_bus
    |> Enum.filter(&(&1[:name] == name))
    |> List.first
  end
end
