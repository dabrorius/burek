module Burek
  module FileHelpers

     def self.open_each_file 
      for_each_file do |file_name|      
        File.open(file_name, "rb:UTF-8") do |file|
          contents = file.read
          yield contents, file_name
        end
      end
    end

    def self.for_each_file
      Burek.config.get(:search_folders).each do |folder|
        Dir.glob(folder) do |file_name|
          unless File.directory?(file_name)
             yield file_name
          end
        end
      end
    end

    def self.create_folder_if_missing(path)
      Dir.mkdir(path) unless File.directory?(path)
    end

  end
end