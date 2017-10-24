module Burek
  module ViewHelpers
    def self.choose
      if Burek.config.highlight_missing_translations
        HighlightingHelper
      else
        QuietHelper
      end
    end

    module HighlightingHelper
      def burek(key)
        raw "<span style='background-color:red;'>#{key}</span>"
      end
    end

    module QuietHelper
      def burek(key)
        key
      end
    end
  end
end
