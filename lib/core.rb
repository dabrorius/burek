require 'config'
require 'yaml'

module Burek

  module Core

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

    def self.find_burek_calls_in_files
      new_translations = {}
      # Iterate all defined subfolders subfolders
      open_each_file do |contents, file_name|      
        filtered_path = Burek::Core.filter_path(file_name)
        matches = Burek::Parser.find_burek_calls(contents)
        matches.each do |value|
          key = filtered_path + "/" + value.downcase.gsub(' ','_')
          new_translations[key] = value
        end
      end
      return new_translations
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

    def self.translations_hash_to_file(translations_hash, translation_file)
      clean_yaml = Burek::Parser.yaml_to_i18n_file(translations_hash.to_yaml) 
      translation_file.gsub!("//","/")
      File.write(translation_file, clean_yaml) #Store
    end

    def self.run_burek
      # Create translations folder if missing
      create_folder_if_missing Burek.config(:translations_path)

      new_translations = find_burek_calls_in_files

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
          translations_hash_to_file(translations_hash, translation_file)
        end

        
      end

      # Replace all burek calls with regular translation calls
      replace_burek_calls_in_files(to_replace)
    end

    def self.replace_burek_calls_in_files(to_replace)
      open_each_file do |content,file_name|      
        processed_content = Burek::Parser.replace_burek_calls(content, to_replace)
        unless processed_content.nil?
          File.open(file_name, 'w') do |output_file|
            output_file.print processed_content
          end
        end
      end
    end

    def self.open_each_file 
      for_each_file do |file_name|      
        File.open(file_name, "rb") do |file|
          contents = file.read
          yield contents, file_name
        end
      end
    end

    def self.for_each_file
      Burek.config(:search_folders).each do |folder|
        Dir.glob(folder) do |file_name|
          unless File.directory?(file_name)
             yield file_name
          end
        end
      end
    end

  end
end
