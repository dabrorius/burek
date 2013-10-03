require 'file_helpers'

module Burek
  module Finder

    def self.find_burek_calls_in_files
      new_translations = {}
      # Iterate all defined subfolders subfolders
      Burek::FileHelpers.open_each_file do |contents, file_name|      
        filtered_path = filter_path(file_name)
        matches = find_burek_calls(contents)
        matches.each do |value|
          key = filtered_path + "/" + value.downcase.gsub(' ','_')
          new_translations[key] = value
        end
      end
      return new_translations
    end

    def self.find_burek_calls(string)
      string.scan(Burek::Core.burek_call_regex).flatten 
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