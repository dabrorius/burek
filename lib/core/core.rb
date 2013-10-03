require 'config'
require 'yaml'
require 'core/burek_replacer'
require 'core/burek_finder'
require 'core/locales_creator'

module Burek

  module Core
    # Main method in burek. It works in three steps:
    #
    # 1. find all burek calls within folders specified in config
    # 2. add new translations to locales files
    # 3. replace all burek calls with regular translation calls
    #
    def self.run_burek
      create_folder_if_missing Burek.config(:translations_path)

      new_translations = Burek::Finder.find_burek_calls_in_files

      to_replace = {}
      # Create files for each locale
      Burek.config(:locales).each do |locale|    
        new_translations.each do |key,value|
          path_parts = key.split("/")
          item_name = path_parts.pop
          path_parts_no_filename = path_parts[0..-2]

          # Figure out file path
          translation_file = Burek::Core.key_to_file_path(key, locale)

          translations_hash = initialize_translations_hash(translation_file, locale)

          # Save info for replacing burek calls with translation calls
          to_replace[value] = path_parts_to_key(path_parts_no_filename, item_name)

          # Nest in hashes
          cur_hash = translations_hash[locale.dup.force_encoding("UTF-8")]
          path_parts_no_filename.each do |item|
            cur_hash[item] = {} unless cur_hash.has_key?(item)
            cur_hash = cur_hash[item]
          end
          cur_hash[item_name] = ( locale == Burek.config(:locales).first ? value.dup.force_encoding("UTF-8") : Burek.config(:translation_placeholder) )

          # Save to file
          Burek::LocalesCreator.translations_hash_to_file(translations_hash, translation_file)
        end

        
      end

      # Replace all burek calls with regular translation calls
      Burek::Replacer.replace_burek_calls_in_files(to_replace)
    end


    def self.burek_call_regex(caption="(?<key>[^\\)]*)")
      Regexp.new("[^a-zA-Z0-9_]burek[ \\t]*\\([ \\t]*('|\")#{caption}\('|\")[^\\)]*\\)")
    end
    
   
    def self.key_to_file_path(key, locale)
      path_parts = key.split("/")
      path_parts.pop

      translation_file = Burek.config(:translations_path) 
      path_parts.each_with_index do |item, index|
        if index == Burek.config(:subfolder_depth) || item == path_parts.last
          translation_file += "#{item}.#{locale}.yml"
          break
        else
          translation_file += "/#{item}/"
          unless File.directory?(translation_file)
            Dir.mkdir(translation_file)
          end
        end
      end
      return translation_file
    end

    def self.filter_path(file_name)
      path = file_name.split('/')
      path.delete_if do |item|
        Burek.config(:ignore_folders_for_key).include? item
      end
      path.last.gsub!(/\.(.*?)$/,'').gsub!(/^_/,'') #strip extenison from file name
      return path.join('/')
    end

    def self.create_folder_if_missing(path)
      Dir.mkdir(path) unless File.directory?(path)
    end


    def self.initialize_translations_hash(translation_file, locale)
      if File.exists?(translation_file)
        translations_hash = YAML::load_file(translation_file) #Load
      else
        translations_hash = {}
        translations_hash[locale.dup.force_encoding("UTF-8")] = {} 
      end
      return translations_hash
    end

    def self.path_parts_to_key(path_parts, item_name)
      regular_translation_key = path_parts.join('.') 
      regular_translation_key += "." unless regular_translation_key.nil? || regular_translation_key.empty?
      regular_translation_key += "#{item_name}"
    end

  end
end
