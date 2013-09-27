require 'yaml'
require 'parser'
require 'core'
require 'config'

namespace :burek do

  desc "Task passes through all views and reports any missing translations"
  task :fetch do
    Burek::core.run_burek
  end
  
end

