require 'file_helpers'

module Burek
  module Finder

    # Searches all files within search folders for burek calls.
    #
    # ==== Returns
    # Hash in whichs values represent burek call captions and keys represent locales file paths in which
    # those captions were found
    #
    def self.find_burek_calls_in_files
      new_translations = {}
      Burek::FileHelpers.open_each_file do |contents, file_name|      
        filtered_path = filter_path(file_name)
        matches = find_burek_calls(contents)
        matches.each do |caption|
          key = filtered_path + "/" + caption_to_key_part(caption)
          new_translations[key] = caption
        end
      end
      return new_translations
    end

    # Sanitizes caption so that it can be used as key part
    def self.caption_to_key_part(caption)
      caption.strip.gsub(/ +/,' ').downcase.gsub(/[^0-9a-z_ ]/i, '').split(' ')[0..3].join('_')
    end

    # Finds burek calls in a string
    #
    # ==== Attributes
    # * +string+ - A string that (possibly) contains burek calls
    #
    # ==== Returns
    # Array of burek call captions
    #
    def self.find_burek_calls(string)
      string.scan(Burek::Core.burek_call_regex).flatten 
    end

    # Removes file extension from a path as well as any folder that is specified as ignored folder in config
    #
    # ==== Attributes
    # * +file_name+ - path in string format that needs to be filtered
    #
    # ==== Returns
    # Filtered path as a string
    #
    def self.filter_path(file_name)
      path = file_name.split('/')
      path.delete_if do |item|
        Burek.config.get(:ignore_folders_for_key).include? item
      end
      path.last.gsub!(/\.(.*?)$/,'').gsub!(/^_/,'') #strip extenison from file name
      return path.join('/')
    end

  end
end