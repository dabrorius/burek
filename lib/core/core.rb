require 'config'
require 'yaml'
require 'core/burek_call'
require 'core/translations_store'

require 'file_helpers'

module Burek

  module Core

    # Main method in burek. It works in three steps:
    #
    # 1. find all burek calls within folders specified in config
    # 2. add new translations to locales files
    # 3. replace all burek calls with regular translation calls
    #
    def self.run_burek
      Burek::FileHelpers.create_folder_if_missing Burek.config.get(:translations_path)

      puts "Searching for burek calls..."
      
      # Initializing translations store
      translations = TranslationsStore.new
      Burek.config.get(:locales).each do |locale|
        filename = "burek.#{locale}.yml"
        file_path = Burek.config.get(:translations_path) + filename
        translations.load_locale locale, file_path
      end

      # Replacing calls and updating translations hash
      Burek::FileHelpers.open_each_file do |contents, file_name|      
        matches = fetch_params_from_string(contents)
        matches.each do |call_params|
          call = burek_call_from_params_string call_params
          translations.push_call call
          contents.gsub!(burek_call_params_regex(call_params),"t('#{call.full_key}')")           
        end
        File.open(file_name, "w:UTF-8") do |f| 
          f.write contents
        end
      end

      # Saving new translations
      Burek.config.get(:locales).each do |locale|
        filename = "burek.#{locale}.yml"
        file_path = Burek.config.get(:translations_path) + filename
        translations.save_locale locale, file_path
      end

      puts "DONE!"
    end

    def self.store_burek_call_to_locale_file(call)
      Burek.config.get(:locales).each do |locale|
        translations_hash_to_file translation_hash, file_path
      end 
    end

    def self.fetch_params_from_string(string)
      string.scan(self.burek_call_params_regex).flatten
    end

    def self.burek_call_from_params_string(params)
      call = "BurekCall.new(#{params})"
      eval call
    end

    private

    # A regex for finiding burek calls
    def self.burek_call_params_regex(caption='([^\)]*)')
      /burek *\(#{caption}\)/
    end
    
  end
end
