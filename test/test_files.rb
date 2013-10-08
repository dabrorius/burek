require 'test/unit'
require 'fileutils'
require 'config'
require 'core/core'
require 'core/locales_creator'

class BurekTesting < Test::Unit::TestCase

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

  def test_big
    setup
    copy_example("test_big.html.erb","/")
    
    Burek::Core.run_burek

    assert_translation_content "test_big.en.yml", {'en' => { 'lorem_ipsum_dolor_sit' => 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.' }}
    assert_translation_content "test_big.fi.yml", {'fi' => { 'lorem_ipsum_dolor_sit' => 'TODO' }}

    assert_file_contents(@views_folder + "/test_big.html.erb", "<h1><%= t('lorem_ipsum_dolor_sit') %></h1>")
    teardown
  end

  def test_depth_0
    setup
    copy_example("test1.html.erb","/")
    
    Burek::Core.run_burek

    assert_translation_content "test1.en.yml", {'en' => { 'welcome' => 'Welcome' }}
    assert_translation_content "test1.fi.yml", {'fi' => { 'welcome' => 'TODO' }}

    assert_file_contents(@views_folder + "/test1.html.erb", "<h1><%= t('welcome') %></h1>")
    teardown
  end

  def test_depth_1
    setup
    copy_example("test1.html.erb","/level1/")

    Burek::Core.run_burek

    assert_translation_content "level1/test1.en.yml", {'en' => { 'level1' => {'welcome' => 'Welcome'} }}
    assert_translation_content "level1/test1.fi.yml", {'fi' => { 'level1' => {'welcome' => 'TODO'} }}

    assert_file_contents(@views_folder + "/level1/test1.html.erb", "<h1><%= t('level1.welcome') %></h1>")
    teardown
  end

  def test_depth_2
    setup
    copy_example("test1.html.erb","/level1/l2/")
    Burek::Core.run_burek

    assert_translation_content "level1/l2/test1.en.yml", {'en' => { 'level1' => { 'l2' => {'welcome' => 'Welcome'}} }}
    assert_translation_content "level1/l2/test1.fi.yml", {'fi' => { 'level1' => { 'l2' => {'welcome' => 'TODO'}} }}

    assert_file_contents(@views_folder + "/level1/l2/test1.html.erb", "<h1><%= t('level1.l2.welcome') %></h1>")
    teardown
  end

  def test_depth_3
    setup
    copy_example("test1.html.erb","/level1/l2/l3/")
    Burek::Core.run_burek

    assert_translation_content "level1/l2/l3.en.yml", {'en' => { 'level1' => { 'l2' => { 'l3' => {'welcome' => 'Welcome'}}} }}
    assert_translation_content "level1/l2/l3.fi.yml", {'fi' => { 'level1' => { 'l2' => { 'l3' => {'welcome' => 'TODO'}}} }}

    assert_file_contents(@views_folder + "/level1/l2/l3/test1.html.erb", "<h1><%= t('level1.l2.l3.welcome') %></h1>")
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
    assert_file_contents "#{@translations_folder}#{path}", Burek::LocalesCreator.yaml_to_i18n_file(expected_content_hash.to_yaml)
  end

  def assert_file_contents(path, expected_content)
    File.open(path, "rb") do |file|
      content = file.read
      assert_equal expected_content, content
    end
  end


end