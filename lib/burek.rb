require 'view_helpers'

module Burek
  class Railtie < Rails::Railtie
    initializer "view_helpers" do
      ActionView::Base.send :include, ViewHelpers
    end

    rake_tasks do
      require_relative '../tasks/tasks'
    end
  end
end
