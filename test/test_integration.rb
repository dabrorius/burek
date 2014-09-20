require 'minitest/autorun'
require 'fileutils'
require 'config'
require 'core/core'

class BurekTesting < Minitest::Test

  def setup
    @temp_folder = "./temp/"
    @examples_folder = "./test/examples/"
    @views_folder = @temp_folder+"views/"
    @translations_folder = @temp_folder+"translations/"

    # Recreate temp folder
    if File.directory?(@temp_folder)
      FileUtils.rm_rf(@temp_folder)
    end
    Dir.mkdir(@temp_folder)
    Dir.mkdir(@views_folder)
    Dir.mkdir(@translations_folder)

    # Set config variables
    Burek.setup do |config|
      config.search_folders = [@views_folder+"**/*"]
      config.translations_path = @translations_folder
      config.ignore_folders_for_key = ['.','temp','views']
      config.locales = ['en','fi']
    end
  end

  def teardown
    if File.directory?(@temp_folder)
      FileUtils.rm_rf(@temp_folder)
    end
  end

  def test_translation_loading
    translations = Burek::TranslationsStore.new
    translations.load_locale(:en, "#{@examples_folder}burek.en.yml")
    translation_hash = translations.get_hash
    assert_equal 'Root translation', translation_hash['en']['root_translation']
    assert_equal 'Welcome home', translation_hash['en']['homepage']['welcome']
    assert_equal 'Goodbye', translation_hash['en']['homepage']['bye']
  end

  def test_translation_writing
    translations_hash = {'en'=>{"root_translation"=>"Root translation", "hi"=>{"hello_world"=>"Hello world"}, "tree"=>{"nest"=>{"nested_translation"=>"Nested translation"}}}}
    output_file = @translations_folder + 'out.en.yml'

    translations = Burek::TranslationsStore.new(translations_hash)
    translations.save_locale(:en, output_file)
    File.open(output_file, "r") do |file|
      content = file.read
      puts "CONTENT"
      puts content
      assert_equal "en:\n  root_translation: Root translation\n  hi:\n    hello_world: Hello world\n  tree:\n    nest:\n      nested_translation: Nested translation\n", content
    end
  end

  def test_depth_0
    setup
    copy_example("test1.html.erb","/")
    
    Burek::Core.run_burek

    assert_translation_content "burek.en.yml", {'en' => { 'welcome' => 'Welcome' }}
    assert_translation_content "burek.fi.yml", {'fi' => { 'welcome' => 'TODO' }}

    assert_file_contents(@views_folder + "/test1.html.erb", "<h1><%= t('welcome') %></h1>")
    teardown
  end

  def copy_example(example, target_folder)
    target = "" if target_folder == "/"

    # Create folders if target is nested
    target_folder_parts = target_folder.split("/")
    current_folder = @views_folder
    target_folder_parts.each do |folder|
      current_folder += "#{folder}/"
      unless File.directory?(current_folder)
        Dir.mkdir(current_folder)
      end
    end

    FileUtils.cp(@examples_folder+example, @views_folder + target_folder + example)
  end

  def assert_translation_content(path, expected_content_hash)
    assert_file_contents "#{@translations_folder}#{path}", expected_content_hash.to_yaml.lines.to_a[1..-1].join
  end

  def assert_file_contents(path, expected_content)
    File.open(path, "rb") do |file|
      content = file.read
      assert_equal expected_content, content
    end
  end
  
end