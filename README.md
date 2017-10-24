# burek

Burek is here to help you with your RoR translations. It's not here to replace rails translation, but to help you manage them. In the end *all* burek calls are replaced with regular translation calls.

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
# config/locales/burek.en.yml
en:
  all_users: All users
```

```ruby
# config/locales/burek.fi.yml
fi:
  all_users: TODO
```

It also replaces all burek calls with regular translation calls

```html
# views/users/index.html
<h1>
  <%= t("all_users") %>
</h1>
```

That's it!

## Additional options

If you don't like translation key that was generated automatically you can specify it in options hash
which is passed as second argument to burek call.

```html
# views/users/index.html
<h1>
  <%= burek("All users", {key: 'users', parent_key: 'levelone.leveltwo'}) %>
</h1>
```

This call will generate following translation file:

```ruby
# config/locales/burek/views/users/index.fi.yml
en:
  levelone:
    leveltwo:
      users: "All users"
```
And replace burek call to t() call with correct key.

```html
# views/users/index.html
<h1>
  <%= t("levelone.leveltwo.users") %>
</h1>
```

## How to install it?

Just add following line to your Gemfile:
```ruby
gem 'burek', '~> 0.6.0'
```

## How to configure it?
You can use default configuration, if you want to override it create following file. You don't have to override all configuration variables, but I listed them all here with brief descriptions. 

```ruby
# config/initializers/burek.rb
Burek.setup do |config|
  config.search_folders = ['./app/views/**/*'] # Where should I look for burek calls?
  config.translations_path = './config/locales/' # Where should I generate translation files?
  config.translation_placeholder = 'TODO' # What should I set as default translation for non-main languages
  config.locales = ['en'] # What locales do you want to use? (NOTE: First locale is considered main)
  config.highlight_missing_translations = false  # Disable/enable the highlighting on an element where Burek is used (default: true)
end
```



