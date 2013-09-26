require 'config'

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

  end
end
