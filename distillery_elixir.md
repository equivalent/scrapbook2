mix help release    # full help


#phoenix build

```
./node_modules/brunch/bin/brunch b -p     # build assets in prod
MIX_ENV=prod mix phoenix.digest
mix release --env=prod


==> Release successfully built!
    You can run it in one of the following ways:
      Interactive: _build/prod/rel/eq8/bin/eq8 console
      Foreground: _build/prod/rel/eq8/bin/eq8 foreground
      Daemon: _build/prod/rel/eq8/bin/eq8 start

```

* https://github.com/bitwalker/distillery-test  # example app
* https://medium.com/@brucepomeroy/deploying-an-elixir-umbrella-project-using-distillery-and-edeliver-b0e8528569e3
