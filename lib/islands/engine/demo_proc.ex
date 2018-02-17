defmodule Islands.Engine.DemoProc do
  @moduledoc false
  def loop() do
    receive do
      message -> IO.puts("I got a message: #{message}")
    end

    loop()
  end
end
