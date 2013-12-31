require 'test/unit'
require 'core/core'


class BurekTesting < Test::Unit::TestCase

  def test_add_to_translation_hash
    # Add new translations
    translations = Burek::TranslationsStore.new

    translations.push_call Burek::BurekCall.new('Root translation' )
    translations.push_call Burek::BurekCall.new('Hello world', {parent_key: 'hi'} )
    translations.push_call Burek::BurekCall.new('Nested translation', {parent_key: 'tree.nest'} )

    translation_hash = translations.get_hash

    assert_equal 'Root translation', translation_hash['en']['root_translation']
    assert_equal 'Hello world', translation_hash['en']['hi']['hello_world']
    assert_equal 'Nested translation', translation_hash['en']['tree']['nest']['nested_translation']

    # Add translations to existing hash
    translations.push_call Burek::BurekCall.new('New root' )
    translations.push_call Burek::BurekCall.new('Bye world', {parent_key: 'hi'} )

    translation_hash = translations.get_hash

    assert_equal 'New root', translation_hash['en']['new_root']
    assert_equal 'Bye world', translation_hash['en']['hi']['bye_world']
  end


end