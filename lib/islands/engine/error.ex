defmodule Islands.Engine.Error do
  @moduledoc false

  require Logger

  @spec log(any, any) :: :ok
  def log(non_matched_value, request) do
    Logger.error(
      "\n\n`handle_call` request:" <>
        "\n#{inspect(request, pretty: true)}" <>
        "\n\n`with` non-matched value:" <>
        "\n#{inspect(non_matched_value, pretty: true)}" <> "\n\n"
    )
  end
end
