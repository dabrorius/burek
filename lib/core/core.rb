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
      new_translations = Burek::Finder.find_burek_calls_in_files
      if new_translations.any?
        new_translations.each do |file, caption|
          puts "\t-> Found '#{caption}' in '#{file}'"
        end
      else
        puts "No burek calls found!"
      end
      
      puts "Adding translations to locale filess..."
      to_replace = Burek::LocalesCreator.create_locales(new_translations)
      
      puts "Repalcing burek calls with translation calls..."
      Burek::Replacer.replace_burek_calls_in_files(to_replace)

      puts "DONE!"
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
    def self.burek_call_params_regex
      /burek *\(([^\)]*)\)/
    end
    
  end
end
