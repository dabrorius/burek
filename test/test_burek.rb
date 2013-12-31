require 'test/unit'
require 'core/core'


class BurekTesting < Test::Unit::TestCase

  def test_fetch_params_from_string
    # Single call
    assert_equal ["'Hello world'"], Burek::Core.fetch_params_from_string("burek('Hello world')")

    # Multiple calls
    assert_equal ["'Hello world'",'"Bye world"'], Burek::Core.fetch_params_from_string("burek('Hello world') burek(\"Bye world\")")
  
    # With whitespace
    assert_equal ["'Hello world'"], Burek::Core.fetch_params_from_string("burek  ('Hello world')")

    # With options params
    assert_equal ["'Hello world', {key: 'hi'}"], Burek::Core.fetch_params_from_string("burek('Hello world', {key: 'hi'})")
  end

=begin
  def test_simple_burek_call_double_quotes
    assert_equal ['Hello world'], Burek::Finder.find_burek_calls("<%= burek('Hello world') %>")
  end

  def test_simple_burek_call_double_quotes
    assert_equal ['Hello world'], Burek::Finder.find_burek_calls("<%= burek(\"Hello world\") %>")
  end

  def test_crowded_burek_call_single_quotes
    assert_equal ['Hello world'], Burek::Finder.find_burek_calls("<%=burek('Hello world')%>")
  end

  def test_crowded_burek_call_double_quotes
    assert_equal ['Hello world'], Burek::Finder.find_burek_calls("<%=burek(\"Hello world\")%>")
  end

  def test_burek_replacer
    assert_equal "<%= t('views.main.hello_world') %>", 
    Burek::Replacer.replace_burek_calls("<%= burek('Hello world') %>", {'Hello world' => 'views.main.hello_world'})
  end

  def test_burek_replacer_double_quotes
    assert_equal "<%= t('views.main.hello_world') %>", 
    Burek::Replacer.replace_burek_calls("<%= burek(\"Hello world\") %>", {'Hello world' => 'views.main.hello_world'})
  end

  def test_burek_replacer_multiple_matches
    assert_equal "<%= t('views.main.hello_world') %> Lorem ipsum <%= t('views.main.goodbye') %>", 
    Burek::Replacer.replace_burek_calls("<%= burek('Hello world') %> Lorem ipsum <%= burek('Goodbye') %>", {'Hello world' => 'views.main.hello_world','Goodbye' => 'views.main.goodbye'})
  end

  def test_burek_replacer_with_non_existant_matches
    assert_equal nil, 
    Burek::Replacer.replace_burek_calls("<%= burek('Something different') %>", {'Hello world' => 'views.main.hello_world'})
  end
=end
end