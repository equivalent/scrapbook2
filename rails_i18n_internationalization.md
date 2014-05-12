
## Get current locale (language)

```
I18n.locale
```

### Variables

```haml
-# app/views/home/index.html.erb
=t 'foo.greet_username', user: "Bill", message: "Goodbye"
```

```yaml
# config/locales/en.yml
en:
  foo
    greet_username: "%{message}, %{user}!"
```
