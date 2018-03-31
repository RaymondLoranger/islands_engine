use Mix.Config

config :islands_engine,
  book_ref:
    """
    Based on the book [Functional Web Development]
    (https://pragprog.com/book/lhelph/functional-web-development-
    with-elixir-otp-and-phoenix) by Lance Halvorsen.
    """
    |> String.replace("\n", "")
