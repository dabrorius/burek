module Burek

  @@config_hash = {
    search_folders: ['./app/views/**/*'],
    translations_path: './config/locales/burek/',
    translation_placeholder: 'TODO',
    ignore_folders_for_key: ['.','app'],
    subfolder_depth: 2,
    locales: ['en','fi']
  }

  def self.set_config(key, value)
    @@config_hash[key] = value
  end
  
  def self.config(key)
    raise 'Unknown config key!' unless @@config_hash.has_key? key
    @@config_hash[key]
  end
  
end
