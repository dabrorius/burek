# encoding: UTF-8
require 'rails/view_helpers'
require 'core/core'

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
