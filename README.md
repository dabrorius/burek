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

## How to install it?

Just add following line to your Gemfile:
```ruby
gem "burek"
```
## How to configure it?
You can use default configuration, if you want to override it create following file. You don't have to override all configuration variables, but I listed them all here with brief descriptions. 

```ruby
# config/initializers/burek.rb
Burek.setup do |config|
  config.search_folders = ['./app/views/**/*'] # Where should I look for burek calls?
  config.translations_path = './config/locales/burek/' # Where should I generate translation files?
  config.translation_placeholder = 'TODO' # What should I set as default translation for non-main languages
  config.locales = ['en'] # What locales do you want to use? (NOTE: First locale is considered main)

  # NOTE: Burek generates your translation keys depending on file path where burek call was found.
  config.ignore_folders_for_key = ['.','app'] # What folders should be ignored when generating translation key

  # NOTE: When generating locale files they are nested in subfolders that are generated from translation key
  config.subfolder_depth = 2 # How deep should I nest translation files in subfolders?
end
```



