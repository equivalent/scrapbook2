# Common Phoenix web framework (Elixir) tricks

Most of these are from the [Programming Phenix book](https://pragprog.com/book/phoenix/programming-phoenix)


## Router

```ex
  # ...
  scope "/", Rumbl do
    pipe_through :browser # Use the default browser stack

    #using resources
    resources "/users", UserController, only: [:index, :show, :new, :create]

    # hardcoded
    get "/users", UserController, :index
    get "/users/:id/edit", UserController, :edit
    get "/users/new", UserController, :new
    get "/users/:id", UserController, :show
    post "/users", UserController, :create
    patch "/users/:id", UserController, :update
    put "/users/:id", UserController, :update
    delete "/users/:id", UserController, :delete

    get "/", PageController, :index
  end
  # ...
```

```bash
mix phoenix.routes
```

## Ecto

`iex -S mix`

```ex
alias Rumbl.Repo
alias Rumbl.User

Repo.insert(%User{name: "Jose", username: "josevalim", password_hash: "<3<3elixir"})
Repo.all(User)
Repo.get(User, 1)

```


## Render template in iex

this can be a partial or entire template

```ex
user = Rumbl.Repo.get(Rumbl.User,"1") 
view = Rumbl.UserView.render("user.html", user: user)
Phoenix.HTML.safe_to_string(view)
```


## Memory based repo

add `web/models/user.ex`

```ex
defmodule User do
  defstruct [:id, :name, :username, :password]
end
```

edit: `lib/rumbl.ex`

```ex
defmodule Rumbl.Repo do
  # use Ecto.Repo, otp_app: :rumbl

  def all(Rumbl.User) do
    [%Rumbl.User{id: "1", name: "José", username: "josevalim", password: "elixir"},
     %Rumbl.User{id: "2", name: "Bruce", username: "redrapids", password: "7langs"},
     %Rumbl.User{id: "3", name: "Chris", username: "chrismccord", password: "phx"}]
  end
  def all(_module), do: []

  def get(module, id) do
    Enum.find all(module), fn map -> map.id == id end
  end

  def get_by(module, params) do
    Enum.find all(module), fn map ->
      Enum.all?(params, fn {key, val} -> Map.get(map, key) == val end)
    end
  end
end
```

edit `lib/rumbl.ex`

```ex
defmodule Rumbl do
  # ...

  def start(_type, _args) do
    # ...

    children = [
      # ...
      # supervisor(Rumbl.Repo, []),  #comment out this line
      # ...
    ]

    # ...
```

```bash
$ iex -S mix
iex(1)> alias Rumbl.User
Rumbl.User
iex(2)> alias Rumbl.Repo
Rumbl.Repo
iex(3)> Repo.all User
[%Rumbl.User{id: "1", name: "José", password: "elixir", username: "josevalim"},
 %Rumbl.User{id: "2", name: "Bruce", password: "7langs", username: "redrapids"},
 %Rumbl.User{id: "3", name: "Chris", password: "phx", username: "chrismccord"}]
```

source code: https://github.com/equivalent/rumbl/tree/01-memory-based-repo (be sure you stay on branch `01-memory-based-repo`)
