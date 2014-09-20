require 'minitest/autorun'
require 'core/core'


class BurekTesting < Minitest::Test

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

  def test_burek_call_class
    call = Burek::BurekCall.new('Hello world', {key: 'hi'} )
    assert_equal 'Hello world', call.translation
    assert_equal 'hi', call.key
  end

  def test_burek_call_from_params_string
    # Passing only translations
    call = Burek::Core.burek_call_from_params_string("'Hello world'")
    assert_equal 'Hello world', call.translation

    # Passing only translations with options hash
    call = Burek::Core.burek_call_from_params_string("'Hello world', {key: 'hi'}")
    assert_equal 'Hello world', call.translation
    assert_equal 'hi', call.key
  end

end