require 'yaml'
require 'core/core'
require 'config'

namespace :burek do

  desc "Task passes through all views and reports any missing translations"
  task :fetch do
    Burek::Core.run_burek
  end
  
end

