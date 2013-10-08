require 'yaml'
require 'core/core'
require 'config'

namespace :burek do

  desc "Task passes through all views and reports any missing translations"
  task :fetch => :environment do
    Burek::Core.run_burek
  end

  desc "Show loaded configuration"
  task :show_config => :environment do
    puts Burek.configuration.hash
  end
  
end

