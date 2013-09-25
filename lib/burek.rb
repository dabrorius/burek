module Burek
  class Railtie < Rails::Railtie
    initializer "view_helpers" do
      ActionView::Base.send :include, ViewHelpers
    end

    rake_tasks do
      require_relative '../tasks/tasks'
    end
  end

  module ViewHelpers
    def burek(key)
      "BUREK GEM! #{key}"
    end
  end
end
