burek
=====

Burek is here to help you with your RoR translations, this is how it works:

1. You call burek in your view files 

```ruby
# views/users/index.html
<h1>
  <%= burek("All users") %>
</h1>
```

2. You fetch translations

```bash
rake burek:fetch
```

3. Burek generates translation files for you
If you defined you want to use en and fi locales, and en is your main locale burek generates following files

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

```ruby
# views/users/index.html
<h1>
  <%= t("views.users.all_users") %>
</h1>
```

That's it! Cool isn't it?
