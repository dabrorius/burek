module Burek
  module LocalesCreator

    # Creates new or updates exisitng locales files. Called by Burek::Finder
    #
    # ==== Attributes
    # * +new_translations+ - A hash of new translations that were found in search folders.
    #                        Values represent burek call captions and keys represent locales file paths in which those captions were found.
    #
    # ==== Returns
    # A hash of burek calls that need to be replaced by translation calls.
    # Keys contain captions of burek calls and values contain key which translation keys should contain.
    #
    def self.create_locales(new_translations)
      to_replace = {}
      # Create files for each locale
      Burek.config(:locales).each do |locale|    
        new_translations.each do |key,value|
          path_parts = key.split("/")
          item_name = path_parts.pop
          path_parts_no_filename = path_parts[0..-2]

          translation_file = key_to_file_path(key, locale)
          translations_hash = initialize_translations_hash(translation_file, locale)

          # Save info for replacing burek calls with translation calls.
          # Keys are burek call captions and values are keys to be used in translation calls.
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

      return to_replace
    end

    # Stores a translation hash in to a file
    #
    def self.translations_hash_to_file(translations_hash, translation_file)
      clean_yaml = yaml_to_i18n_file(translations_hash.to_yaml) 
      translation_file.gsub!("//","/")
      File.write(translation_file, clean_yaml) #Store
    end

    # Removes a first line from a yaml file which is added to standard YAML files
    # but rails does not like it. It continas ---- or something like that
    #
    def self.yaml_to_i18n_file(yaml)
      yaml.lines.to_a[1..-1].join
    end
  
    # Intializes a translation hash by either loading existing translation file
    # or creating a hash that contains an empty hash under key which is name of current locale.
    def self.initialize_translations_hash(translation_file, locale)
      if File.exists?(translation_file)
        translations_hash = YAML::load_file(translation_file) #Load
      else
        translations_hash = {}
        translations_hash[locale.dup.force_encoding("UTF-8")] = {} 
      end
      return translations_hash
    end

    # Creates a translation call key from path where burek call was found and burek call caption
    #
    def self.path_parts_to_key(path_parts, item_name)
      regular_translation_key = path_parts.join('.') 
      regular_translation_key += "." unless regular_translation_key.nil? || regular_translation_key.empty?
      regular_translation_key += "#{item_name}"
    end

    # Generates a file path to locales file from a file path where burek call was found.
    # It will nest locales file under same subfolders in which burek call was found.
    # If burek call was nested deeper then defined as subfolder depth limit in config file
    # it will nest it under first X folders (where x is subfolder depth limit)
    #
    # ==== Attributes
    # * +key+ - file path where burek call was found
    # * +locale+ - locale for which this file is created
    #
    # ==== Returns
    # A string that contains a path where locale file should be created.
    # NOTE: Even though subfolders are created, the actuall locale file is NOT created.
    #
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

  end
end
