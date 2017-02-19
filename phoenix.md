## phoenix changeset

```
 ch = User.registration_changeset(%User{}, %{username: "max", name: "Max", password: "123"})
```

## phoenix generate migation

```
mix ecto.gen.migration "create_user"
```

## phoenix helpers

```
Phoenix.HTML.Link.link("Home", to: "/")
Phoenix.HTML.Link.link("Delete", to: "/", method: "delete")

# user = Rumbl.Repo.get(Rumbl.User, "1")
# Phoenix.HTML.Link.link("View", to: Rumbl.Router.user_path(@conn, :show, user.id))
# link "View", to: user_path(@conn, :show, user.id)
```

## phoenix structs

```
defmodule Rumbl.User do
  defstruct [:id, :name, :username, :password]
end

alias Rumbl.User

user = %{usernmae: "jose", password: "elixir"}
user.username
# ** (KeyError) key :username not found in: %{password: "elixir",
usernmae: "jose"}

jose = %User{name: "Jose Valim"}
jose.name # "Jose Valim"

chris = %User{nmae: "chris"}
#** (CompileError) iex:3: unknown key :nmae for struct User
```

## IEx and phoenix


```
cd ./my-phoenix-project
iex -S mix
alias MyPhoenixProject.Categorory  # model
alias MyPhoenixProject.Repo
Repo.all(Category)

```

## debugging pry

```
iex -S mix phoenix.server

require IEx

IEx.pry

```

------------------------------------------------------------

```
#  first steps (install phoenix)

mix local hex
mix archive.install https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez


```



```
mix hex.info
iex -S mix phoenix.server

mix ecto.create # creates db
mix ecto.migrate # run migartion

# generator
mix phoenix.gen.html Teacher teachers name:string email:string master_id:integer

```


```iex
defmodule Teacher do
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :email, :bio, :number_of_pets])
    |> validate_required([:name, :email, :bio, :number_of_pets])
    |> validate_length(:bio, min: 2)
    |> validate_length(:bio, max: 140)
    |> validate_format(:email, ~r/@/)
  end
end

ch = MyProject.Teacher.changeset(%Teacher{}, %{})
ch.valid?  # false

ch.errors
#[name: {"can't be blank", []}, email: {"can't be blank", []}]

```
