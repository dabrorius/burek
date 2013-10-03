require 'config'
require 'yaml'
require 'core/burek_replacer'
require 'core/burek_finder'
require 'core/locales_creator'
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
      Burek::FileHelpers.create_folder_if_missing Burek.config(:translations_path)

      new_translations = Burek::Finder.find_burek_calls_in_files
      to_replace = Burek::LocalesCreator.create_locales(new_translations)
      Burek::Replacer.replace_burek_calls_in_files(to_replace)
    end

    # A regex for finiding burek calls
    # 
    # It is used by Burek::Finder and Burek::Replacer.
    # Example calls it can find
    # * burek('Hello world')
    # * burek("Hello world")
    # * burek ( "Hello world" )
    #
    # ==== Attributes
    # * +caption+ - Use it to find burek call with specific caption.
    #               By default it will accept any string and capture it in group named 'key'.
    #
    def self.burek_call_regex(caption="(?<key>[^\\)]*)")
      Regexp.new("[^a-zA-Z0-9_]burek[ \\t]*\\([ \\t]*('|\")#{caption}\('|\")[^\\)]*\\)")
    end
    
  end
end