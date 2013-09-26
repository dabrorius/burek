module Burek
  module Parser

    def self.find_burek_calls(string)
      string.scan(/[^a-zA-Z0-9_]burek[ \t]*\([ \t]*\'(?<key>[^\)]*)\'[^\)]*\)/).flatten 
    end

    def self.replace_burek_calls(contents, to_replace)
      matches = Burek::Parser.find_burek_calls(contents)
      matches.each do |value|
        regex_str = "[^a-zA-Z0-9_]burek[ \\t]*\\([ \\t]*\\'#{value}\\'[^\\)]*\\)"
        contents.gsub!(Regexp.new(regex_str)," t('#{to_replace[value]}')")
      end

      return contents unless matches.empty?
    end


  end
end
