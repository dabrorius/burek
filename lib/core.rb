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

    def self.run_burek
      # Create translations folder if missing
      unless File.directory?(Burek.config(:translations_path))
        Dir.mkdir(Burek.config(:translations_path))
      end

      new_translations = {}
      # Iterate all defined subfolders subfolders
      for_each_file do |file_name|      
        File.open(file_name, "rb") do |file|
          contents = file.read

          filtered_path = Burek::Core.filter_path(file_name)
          matches = Burek::Parser.find_burek_calls(contents)
          matches.each do |value|
            key = filtered_path + "/" + value.downcase.gsub(' ','_')
            new_translations[key] = value
          end
        end
      end

      to_replace = {}
      # Create files for each locale
      Burek.config(:locales).each do |locale|    
        new_translations.each do |key,value|
          path_parts = key.split("/")
          item_name = path_parts.pop
          path_parts_no_filename = path_parts[0..-2]

          # Figure out file path
          translation_file = Burek::Core.key_to_file_path(key, locale)

          # Initialize translations hash
          if File.exists?(translation_file)
            translations_hash = YAML::load_file(translation_file) #Load
          else
            translations_hash = {}
            translations_hash[locale.dup.force_encoding("UTF-8")] = {} 
          end

          # Save info for replacing burek calls with translation calls
          regular_translation_key = path_parts_no_filename.join('.') 
          regular_translation_key += "." unless regular_translation_key.nil? || regular_translation_key.empty?
          regular_translation_key += "#{item_name}"
          to_replace[value] = regular_translation_key

          # Nest in hashes
          cur_hash = translations_hash[locale.dup.force_encoding("UTF-8")]
          path_parts_no_filename.each do |item|
            cur_hash[item] = {} unless cur_hash.has_key?(item)
            cur_hash = cur_hash[item]
          end
          cur_hash[item_name] = ( locale == Burek.config(:locales).first ? value.dup.force_encoding("UTF-8") : Burek.config(:translation_placeholder) )

          # Save to file
          clean_yaml = Burek::Parser.yaml_to_i18n_file(translations_hash.to_yaml) 
          translation_file.gsub!("//","/")
          File.write(translation_file, clean_yaml) #Store
        end

        
      end

      # Replace all burek calls with regular translation calls
      for_each_file do |file_name|      
        File.open(file_name, 'r') do |file|
          content = file.read
          processed_content = Burek::Parser.replace_burek_calls(content, to_replace)
          unless processed_content.nil?
            File.open(file_name, 'w') do |output_file|
              output_file.print processed_content
            end
          end
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
