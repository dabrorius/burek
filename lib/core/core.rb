require 'config'
require 'yaml'
require 'core/burek_call'
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
      
      Burek::FileHelpers.open_each_file do |contents, file_name|      
        matches = fetch_params_from_string(contents)
        matches.each do |call_params|
          call = burek_call_from_params_string call_params
          store_burek_call_to_locale_file call
          puts "REGEX #{burek_call_params_regex(call.translation)}"
          contents.gsub!(burek_call_params_regex(call_params),"t('#{call.full_key}')")           
        end
        puts "=== === === ==="
        puts contents
        File.open(file_name, "w:UTF-8") do |f| 
          f.write contents
        end
      end

      puts "DONE!"
    end

    def self.store_burek_call_to_locale_file(call)
      Burek.config.get(:locales).each do |locale|
        filename = "burek.#{locale}.yml"
        file_path = Burek.config.get(:translations_path) + filename
        translation_hash = initialize_translations_hash(file_path, locale)
        add_to_translation_hash locale, [call], translation_hash
        translations_hash_to_file translation_hash, file_path
      end 
    end


    # Intializes a translation hash by either loading existing translation file
    # or creating a hash that contains an empty hash under key which is name of current locale.
    def self.initialize_translations_hash(translation_file, locale)
      if File.exists?(translation_file)
        translations_hash = YAML::load_file(translation_file) #Load
      else
        translations_hash = {}
        translations_hash[locale] = {} 
      end
      return translations_hash
    end

    # Stores a translation hash in to a file
    #
    def self.translations_hash_to_file(translations_hash, translation_file)
      yaml = translations_hash.to_yaml
      clean_yaml = yaml.lines.to_a[1..-1].join # Remove first line from YAML
      translation_file.gsub!("//","/")
      File.open(translation_file, "w:UTF-8") do |f| 
        f.write clean_yaml
      end
    end

    def self.add_to_translation_hash(locale, calls, translations_hash={})
      locale = locale.to_s # if it was symbol
      # Initialize hash for current locale
      translations_hash[locale] = {} unless translations_hash.has_key?(locale)

      calls.each do |call|
        cur_hash = translations_hash[locale]
        call.parent_key_array.each do |item|
          cur_hash[item] = {} unless cur_hash.has_key?(item)
          cur_hash = cur_hash[item]
        end
        cur_hash[call.key] = call.translation(locale)
      end

      return translations_hash
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
