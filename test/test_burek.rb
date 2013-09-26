require 'test/unit'
require 'parser'

class BurekTesting < Test::Unit::TestCase

  def simple_burek_call_single_quotes
    assert_equal ['Hello world'], Burek::Parser.find_burek_calls("<%= burek('Hello world') %>")
  end

  def simple_burek_call_double_quotes
    assert_equal ['Hello world'], Burek::Parser.find_burek_calls("<%= burek(\"Hello world\") %>")
  end

  def crowded_burek_call_single_quotes
    assert_equal ['Hello world'], Burek::Parser.find_burek_calls("<%=burek('Hello world')%>")
  end

  def crowded_burek_call_double_quotes
    assert_equal ['Hello world'], Burek::Parser.find_burek_calls("<%=burek(\"Hello world\")%>")
  end

end