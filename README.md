# burek

Burek is here to help you with your RoR translations. 

## How it works?

### 1. Call burek in your view files 

```html
# views/users/index.html
<h1>
  <%= burek("All users") %>
</h1>
```

### 2. Fetch translations with burek rake task

```bash
rake burek:fetch
```

### 3. Burek generates translation files for you.
If you defined, for example, you want to use English and Finnish locales (and English is your main locale).

```ruby
# config/locales/burek/views/users/index.en.yml
en:
  views:
    users:
      all_users: All users
```

```ruby
# config/locales/burek/views/users/index.fi.yml
en:
  views:
    users:
      all_users: TODO
```

It also replaces all burek calls with regular translation calls

```html
# views/users/index.html
<h1>
  <%= t("views.users.all_users") %>
</h1>
```

That's it!
