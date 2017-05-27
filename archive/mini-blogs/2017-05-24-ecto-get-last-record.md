# Ecto Phoenix - get last record in table

Given: I want last Document
And: application name is MyApp

```elixir
require Ecto.Query
last_record = Ecto.Query.from(d in MyApp.Document, limit: 1, order_by: [desc: d.inserted_at]) |> MyApp.Repo.one
```

### Alias version

```elixir
import Ecto.Query
alias MyApp.Repo
alias MyApp.Document

last_record = from(d in Document, limit: 1, order_by: [desc: d.inserted_at]) |> Repo.one

title = "foobar"
last_with_title = from(d in Document, where: d.title == ^title,  limit: 1, order_by: [desc: d.inserted_at]) |> Repo.one
```
