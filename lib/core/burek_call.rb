module Burek
  class BurekCall

    def initialize(translation, options={})
      if translation.is_a?(Hash)
        @translation = translation
      else
        @translation = {default_locale => translation }
      end
      @key = options[:key] || key_from_translation
      @parent_key = options[:parent_key] || ''
    end

    def translation(locale=nil)
      locale ||= default_locale
      locale = locale.to_s
      if @translation.has_key?(locale)
        return @translation[locale]
      else
        return Burek.config.get(:translation_placeholder)
      end
    end

    def key
      @key
    end

    def parent_key
      @parent_key
    end

    def full_key
      if parent_key.nil? || parent_key.length == 0
        key
      else
        parent_key + "." + key
      end
    end

    def parent_key_array
      @parent_key.split('.')
    end

    private

    def key_from_translation
      translation.downcase.gsub(' ','_')
    end

    def default_locale
      Burek.config.get(:locales).first
    end

  end
end