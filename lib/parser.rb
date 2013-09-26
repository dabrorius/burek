module Burek

  module Parser

    def self.find_burek_calls(string)
      string.scan(burek_call_regex).flatten 
    end

    def self.replace_burek_calls(contents, to_replace)
      matches = find_burek_calls(contents)
      changes_made = false
      matches.each do |value|
        if to_replace.has_key?(value)
          contents.gsub!(burek_call_regex(value)," t('#{to_replace[value]}')") 
          changes_made = true
        end
      end

      return contents if changes_made
    end

    def self.yaml_to_i18n_file(yaml)
      yaml.lines.to_a[1..-1].join
    end

    private 

    def self.burek_call_regex(caption="(?<key>[^\\)]*)")
      Regexp.new("[^a-zA-Z0-9_]burek[ \\t]*\\([ \\t]*('|\")#{caption}\('|\")[^\\)]*\\)")
    end

  end
end
