# How to get current enviroment name in Phoenix Elixir

Most straight forward way is like this:

```elixir
if System.get_env("MIX_ENV") == "dev" do
  # ...
end
```

...or

```elixir
Mix.env == :dev
```

**But** the problem is that if you are deploying with Exrm or Distillery
then Mix doesn't work in production
[source](https://stackoverflow.com/questions/35010950/get-current-environment-name/44747870#44747870).

This may not be an issue if you use Docker image that includes Mix (which depends on
usecase may/may not be good enough for you) but in general it's
recommended to do following (solution from SO user [Sheharyar](https://stackoverflow.com/questions/35010950/get-current-environment-name/44747870#44747870) :

Create custom `config/config.exs`:

```elixir
# config/config.exs
config :your_app, env: Mix.env
```

Then you can get environment:

```elixr
Application.get_env(:your_app, :env)
#=> :prod
```
