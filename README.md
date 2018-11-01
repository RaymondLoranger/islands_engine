# Islands Engine

[![Build Status](https://travis-ci.org/RaymondLoranger/islands_engine.svg?branch=master)](https://travis-ci.org/RaymondLoranger/islands_engine)

Models the _Game of Islands_.

##### Based on the book [Functional Web Development](https://pragprog.com/book/lhelph/functional-web-development-with-elixir-otp-and-phoenix) by Lance Halvorsen.

## Installation

Add the `:islands_engine` dependency to your `mix.exs` file:

```elixir
def deps do
  [
    {:islands_engine, "~> 0.1"}
  ]
end
```

## Supervision Tree

The highlighted processes below (supervisors and servers) are fault-tolerant:
if any crashes (or is killed), it is immediately restarted and the system
remains undisturbed.

The processes identified by their PIDs are Game Servers: each holds the state of
a _Game of Islands_. Multiple games can be played simultaneously.

## ![engine_app](images/islands_engine_app.png)

## Note

Package [Islands Text Client](https://hex.pm/packages/islands_text_client) uses
`:islands_engine` as a dependency to play the _Game of Islands_ in the console.
