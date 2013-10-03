require 'file_helpers'
require 'core/burek_finder'

module Burek
  module Replacer

    def self.replace_burek_calls_in_files(to_replace)
      Burek::FileHelpers.open_each_file do |content,file_name|      
        processed_content = replace_burek_calls(content, to_replace)
        unless processed_content.nil?
          File.open(file_name, 'w') do |output_file|
            output_file.print processed_content
          end
        end
      end
    end

    def self.replace_burek_calls(contents, to_replace)
      matches = Burek::Finder.find_burek_calls(contents)
      changes_made = false
      matches.each do |value|
        if to_replace.has_key?(value)
          contents.gsub!(Burek::Core.burek_call_regex(value)," t('#{to_replace[value]}')") 
          changes_made = true
        end
      end

      return contents if changes_made
    end


  end
end