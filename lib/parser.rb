module Burek

  module Parser

    def self.find_burek_calls(string)
      string.scan(/[^a-zA-Z0-9_]burek[ \t]*\([ \t]*('|")(?<key>[^\)]*)('|")[^\)]*\)/).flatten 
    end

    def self.replace_burek_calls(contents, to_replace)
      matches = Burek::Parser.find_burek_calls(contents)
      changes_made = false
      matches.each do |value|
        regex_str = "[^a-zA-Z0-9_]burek[ \\t]*\\([ \\t]*('|\")#{value}\('|\")[^\\)]*\\)"
        if to_replace.has_key?(value)
          contents.gsub!(Regexp.new(regex_str)," t('#{to_replace[value]}')") 
          changes_made = true
        end
      end

      return contents if changes_made
    end

    def self.yaml_to_i18n_file(yaml)
      yaml.lines.to_a[1..-1].join
    end


  end
end
