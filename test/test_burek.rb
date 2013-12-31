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

  def test_add_to_translation_hash
    # Add new translations
    calls_list = []
    calls_list.push Burek::BurekCall.new('Root translation' )
    calls_list.push Burek::BurekCall.new('Hello world', {parent_key: 'hi'} )
    calls_list.push Burek::BurekCall.new('Nested translation', {parent_key: 'tree.nest'} )

    translation_hash = Burek::Core.add_to_translation_hash(:en, calls_list)

    assert_equal 'Root translation', translation_hash['en']['root_translation']
    assert_equal 'Hello world', translation_hash['en']['hi']['hello_world']
    assert_equal 'Nested translation', translation_hash['en']['tree']['nest']['nested_translation']

    # Add translations to existing hash
    calls_list = []
    calls_list.push Burek::BurekCall.new('New root' )
    calls_list.push Burek::BurekCall.new('Bye world', {parent_key: 'hi'} )

    translation_hash = Burek::Core.add_to_translation_hash(:en, calls_list, translation_hash)


    # check if old translations are ok
    assert_equal 'Root translation', translation_hash['en']['root_translation']
    assert_equal 'Hello world', translation_hash['en']['hi']['hello_world']
    assert_equal 'Nested translation', translation_hash['en']['tree']['nest']['nested_translation']

    assert_equal 'New root', translation_hash['en']['new_root']
    assert_equal 'Bye world', translation_hash['en']['hi']['bye_world']
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