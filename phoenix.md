
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
