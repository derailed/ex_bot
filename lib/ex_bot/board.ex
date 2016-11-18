defmodule ExBot.Board do
  @moduledoc """
  Virtual representation of an IOT installation
  """

  # BOZO !! Don't pass the socket here. Let the board
  # tell you about event. All add API to add pins and bus

  @enforce_keys [:gpios, :i2c, :socket, :board]
  defstruct [:gpios, :i2c, :socket, :board]

  alias Sensors.{I2CBus, Gpio}

  @buzz_pin   17
  @laser_pin  23
  @merc_pin    5

  @photo_chan 0
  @temp_chan  1
  @mic_chan   2

  # BOZO !! Have socket monitor board and trigger event
  # BOZO !! Channel should be the controller for the board!

  def buzz() do
    {:ok, buzz} = Gpio.init(@buzz_pin, :output)
    buzz |> Gpio.toggle(:off)
  end

  @doc """
  Build software representation for installed hardware
  """
  def layout(socket) do
    {:ok, buzz} = Gpio.init(@buzz_pin, :output)
    buzz |> Gpio.toggle(:off)
    # socket |> register(:buzz)

    {:ok, laser} = Gpio.init(@laser_pin, :output)
    laser |> Gpio.toggle(:on)
    # socket |> register(:laser)

    {:ok, merc} = Gpio.init(@merc_pin, :input)
    # socket |> register(:merc)

    {:ok, bus} = I2CBus.init("1", 0x48)
    # socket |> register(:temp)
    # socket |> register(:mic)
    # socket |> register(:photo)

    board = %Sensors.Board{
      gpios:  %{laser: laser, buzz: buzz, merc: merc},
      i2c:    bus,
      socket: socket,
      board:  self
    }

    IO.puts "Board Running..."
    spawn(fn -> board |> run() end)

    {:ok, board}
  end

  # defp register(socket, sensor) do
  #   Presence.track(socket, sensor, %{
  #       device:    "browser",
  #       sensor:    sensor,
  #       online_at: inspect(:os.timestamp())
  #   })
  #   socket.channel.push socket, "presence_state", Presence.list(socket)
  # end

  defp send(socket, topic, val) do
    socket.channel.handle_out(
      Atom.to_string(topic),
      %{val: val},
      socket
    )
  end

  def run(board) do
    val = board.bus |> I2CBus.read(@photo_chan)
    # IO.puts "Laser: #{val}"
    board.socket |> send(:laser, val)

    val = board.bus |> I2CBus.read(@temp_chan)
    # IO.puts "Temp: #{val}"
    board.socket |> send(:temp, val)

    val = board.bus |> I2CBus.read(@mic_chan)
    # IO.puts "Mic: #{val}"
    board.socket |> send(:mic, val)

    val = Gpio.read(board.gpios.merc)
    # IO.puts "Merc: #{val}"
    board.socket |> send(:merc, val)

    board.gpios.buzz |> Gpio.toggle(:off)

    :timer.sleep(1_000)
    run(board)
  end
end