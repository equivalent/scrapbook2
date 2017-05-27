# Elixir - update struct value

[https://elixir-lang.org/getting-started/structs.html](https://elixir-lang.org/getting-started/structs.html)

```elixir
user = %User{age: 27, name: "John"}
user = %User{ user | last_name: "Smith"}
```
