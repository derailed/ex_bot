defmodule ExBot.Devices.LCD do
  use Bitwise

  def connect(device, ic2_address) do
    I2c.start_link(device, ic2_address)
  end

  def display(pid, text, delay \\ 2_000) do
     lines = String.split(text, "\n")
     x = 0
     for l <- lines do
        pid |> write(x, 0, l |> String.to_char_list)
        x = x+1
      end
     :timer.sleep(delay)
     clear(pid)
  end

  def init(pid) do
    send_command(pid, 0x33)
    :timer.sleep(5)
    send_command(pid, 0x32)
    :timer.sleep(5)
    send_command(pid, 0x28)
    :timer.sleep(5)
    send_command(pid, 0x0c)
    :timer.sleep(5)
    send_command(pid, 0x01)
    # I2c.write(pid, 0x08 ||| 0x08)
  end

  def send_command(pid, c) do
    b = c &&& 0xf0
    b = b ||| 0x04
    write_word(pid, b)
    :timer.sleep(2)

    b = b &&& 0xfb
    write_word(pid, b)

    b = c &&& 0x0f
    b = b <<< 4
    b = b ||| 0x04
    write_word(pid, b)
    :timer.sleep(2)

    b = b &&& 0xfb
    write_word(pid, b)
  end

  def send_data(pid, d) do
    b = (d &&& 0xf0)
    b = (b ||| 0x05)
    write_word(pid, b)
    :timer.sleep(2)

    b = b &&& 0xfb
    write_word(pid, b)

    b = (d &&& 0x0f)
    b = (b <<< 4)
    b = (b ||| 0x05)
    write_word(pid, b)
    :timer.sleep(2)

    b = b &&& 0xfb
    write_word(pid, b)
  end

  defp clear(pid) do
    send_command(pid, 0x01)
  end

  defp write(pid, x, y, chars) do
    addr = 0x80 + 0x40 * (y + x)
    send_command(pid, addr)

    for c <- chars, do: send_data(pid, c)
  end

  defp write_word(pid, buff) do
    b = buff ||| 0x08
    I2c.write(pid, <<b>>)
  end
end