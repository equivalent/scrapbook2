# Phoenix increase timeout when debugging with IEx.pry in ExUnit

Phoenix, Ecto and ExUnit have some
default timeouts. So once you start debugging you have maybe 10 or 15
seconds before you are kicked out from the process.

> If you don't know how to debug Elixir / Phoenix check [How to debug Phoenix / Elixir application](http://www.eq8.eu/tils/24-how-to-debug-phoenix-elixir-application)

## How to avoid timeout

#### ExUnit timeout:

If you're getting:

`** (ExUnit.TimeoutError) test timed out after 60000ms.`

Then you need to exit your `test/test_helper.exs`:

```elixir
ExUnit.configure(timeout: :infinity)  # add this
ExUnit.start
# ...
```

#### Ecto / Repo / Postgres timeout:


If you're getting:

` [error] Postgrex.Protocol (#PID<0.319.0>) disconnected: **(DBConnection.ConnectionError) owner #PID<0.401.0> timed out because it owned the connection for longer than 15000ms`

Then you need to add timeout to your `config/test.exs` repo config:


```elixir
# ...
config :myapp, MyApp.Repo,
  adapter: Ecto.Adapters.Postgres,     # not important
  username: "mydatabaseuser",          # not important
  database: "myapp_test",              # not important
  hostname: "localhost",               # not important
  pool: Ecto.Adapters.SQL.Sandbox,     # not important
  #ownership_timeout: 999999           # important - increse timeout
# ...
```

source: [https://github.com/elixir-ecto/ecto/blob/master/lib/ecto/adapters/sql/sandbox.ex](https://github.com/elixir-ecto/ecto/blob/master/lib/ecto/adapters/sql/sandbox.ex)

## Relevant Blogs

* [How to debug Phoenix / Elixir application](http://www.eq8.eu/tils/24-how-to-debug-phoenix-elixir-application)
* [ExUnit - Wait for Genserver cast in test](http://www.eq8.eu/tils/19-exunit-wait-for-genserver-cast-in-test)


