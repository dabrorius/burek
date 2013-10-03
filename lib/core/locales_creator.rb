module Burek
  module LocalesCreator

    def self.translations_hash_to_file(translations_hash, translation_file)
      clean_yaml = yaml_to_i18n_file(translations_hash.to_yaml) 
      translation_file.gsub!("//","/")
      File.write(translation_file, clean_yaml) #Store
    end

    def self.yaml_to_i18n_file(yaml)
      yaml.lines.to_a[1..-1].join
    end
  
  end
end
