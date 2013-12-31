module Burek

  module ViewHelpers
    def burek(key)
      raw "<span style='background-color:red;'>#{key}</span>"
    end
  end

end
