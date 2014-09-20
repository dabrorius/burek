require 'yaml'

module Burek

  class BurekConfiguration
    def initialize(hash)
      @hash = hash
    end

    def hash
      @hash
    end

    def get(key)
      hash[key]
    end

    def method_missing(m, *args, &block)
      key = m.to_s.gsub('=','').to_sym
      raise 'Unknown config key!' unless @hash.has_key? key
      @hash[key] = args.first
    end
  end

  @@configuration = BurekConfiguration.new({
    search_folders: ['./app/views/**/*'],
    translations_path: './config/locales/',
    translation_placeholder: 'TODO',
    ignore_folders_for_key: ['.','app'],
    subfolder_depth: 2,
    locales: ['en']
  })

  def self.setup
    yield @@configuration
  end

  def self.configuration
    @@configuration
  end

  def self.config
    configuration
  end
  
end

