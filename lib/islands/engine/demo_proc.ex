defmodule Islands.Engine.DemoProc do
  @moduledoc false

  @spec loop_test() :: :ok
  def loop_test() do
    me = self()

    spawn_link(fn ->
      for _ <- 1..2 do
        Process.sleep(2000)
        send(me, "Still alive!")
      end
    end)

    IO.puts("About to enter receive loop...")
    loop()
    IO.puts("Just exited receive loop...")
  end

  ## Private functions

  @spec loop() :: no_return
  defp loop() do
    receive do
      message ->
        IO.puts("I got a message: #{inspect(message)}")
        loop()
    after
      5000 ->
        IO.puts(:stderr, "No message in 5 seconds")
    end
  end
end
