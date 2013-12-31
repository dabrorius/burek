module Burek

  class TranslationsStore

    def initialize(translations_hash={})
      @translations_hash = translations_hash
    end

    def load_locale(locale, file_path)
      locale = locale.to_s
      if File.exists?(file_path)
        @translations_hash = YAML::load_file(file_path) #Load
      else
        @translations_hash[locale] = {} 
      end
    end

    def save_locale(locale, file_path)
      locale = locale.to_s
      File.open(file_path, "w:UTF-8") do |f| 
        f.write locale_yaml(locale)
      end
    end

    def push_call(call)

      Burek.config.get(:locales).each do |locale|
        locale = locale.to_s # if it was symbol
        # Initialize hash for current locale
        @translations_hash[locale] = {} unless @translations_hash.has_key?(locale)

        # Nest hash
        cur_hash = @translations_hash[locale]
        call.parent_key_array.each do |item|
          cur_hash[item] = {} unless cur_hash.has_key?(item)
          cur_hash = cur_hash[item]
        end
        cur_hash[call.key] = call.translation(locale)
      end

    end

    def get_hash
      @translations_hash
    end

    private

    def locale_yaml(locale)
      yaml = {locale => @translations_hash[locale] }.to_yaml # Pluck only one top level key
      clean_yaml = yaml.lines.to_a[1..-1].join # Clean up first line
      return clean_yaml
    end

  end

end