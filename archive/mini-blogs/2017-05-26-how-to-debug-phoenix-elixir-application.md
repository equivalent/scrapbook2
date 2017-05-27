# How to debug Phoenix / Elixir application

## How to debug ExUnit test:

Normaly when you want to run your elixir/phoenix tests you run it with:

```bash
mix test
```

If you want to debug Elixir code in middle of test execution you can place
this inside your elixir file:

```elixir
# ...
require IEx; IEx.pry
# ...
```

...and run your tests with:

```bash
iex -S mix test
```

## How to debug Phoenix in development:

You can actually do this with development code to and run your
Phoenix server `iex -S mix phoenix.server`. Then you can debug
directly from the terminal where you run the server.

## Relevant Blogs

*  [Phoenix increase timeout when debugging with IEx.pry in ExUnit](http://www.eq8.eu/tils/25-phoenix-increase-timeout-when-debugging-with-iex-pry-in-exunit)
