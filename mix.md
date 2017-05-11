

# update dependancies

```sh
cd my_projct
mix deps.update
```


# restart dependancies


```
mix deps.clean fs
mix deps.get
```

# ecto

## create db

```
mix ecto.create
```



# custom mix

```
$ mkdir lib/mix/tasks
vim lib/mix/tasks/myapp.subscribe.ex
```

```ex
defmodule Mix.Tasks.Myapp.Subscribe do
  use Mix.Task

  @shortdoc "subscribe to SNS topic"

  @moduledoc """
  This is where we would put any long form documentation or doctests.
  """

  def run(endpoint) do

    # because this is a phoenix mix task you may need to start "all apps" before rest of code is executed
    Mix.Tasks.App.Start.run([]) # This will start all apps
    # ... if you just need  single app run this :
    #
    # Application.ensure_all_started(:myapp)

    Mix.shell.info "registering endpoint #{endpoint} to sns topic"
    ExAws.SNS.subscribe("arn:aws:sns:eu-west-1:800571264173:mytopic","http", "#{endpoint}/subscribe") |> ExAws.request
  end

  # We can define other functions as needed here.
  # end
end
```

```
$ mix myapp.subscribe http://my-endpoint.com
```
