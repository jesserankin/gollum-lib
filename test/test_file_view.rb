# ~*~ encoding: utf-8 ~*~
require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))
require File.expand_path '../../lib/gollum-lib/file_view', __FILE__

class FakeSane
  def clean(data)
    data
  end
end

class FakeWiki
  def sanitizer
    FakeSane.new
  end
end

class FakePage
  def initialize(filepath)
    @filepath = filepath
  end

  def wiki
    FakeWiki.new
  end

  # From page.rb
  def filename_stripped
    ::File.basename(@filepath, ::File.extname(@filepath))
  end

  def filename
    ::File.basename(@filepath)
  end

  def path
    return @filepath
  end

  # From page.rb
  def name
    self.class.canonicalize_filename @filepath
  end

  # From page.rb
  def self.strip_filename filename
    ::File.basename(filename, ::File.extname(filename))
  end

  # From page.rb
  def self.canonicalize_filename filename
    strip_filename(filename).gsub('-', ' ')
  end
end

class FakePages
  def initialize(filepath_array)
    @array = filepath_array.map { |filepath| FakePage.new filepath }
  end

  def first
    @array.first
  end

  def size
    @array.size
  end

  def [] index
    @array[index]
  end
end

def view(pages)
  Gollum::FileView.new(pages).render_files
end

def test_path
  @test_path ||= File.expand_path('../file_view/', __FILE__) + '/'
end

def read(file)
  File.read test_path + file + '.txt'
end

# For creating expected files.
# write name, actual
def write(file, content)
  File.open(test_path + file + '.txt', 'w') do |f|
    f.write content
  end
end

def check(name, pages_array)
  pages    = FakePages.new pages_array
  expected = read name
  actual   = view pages

  # Uncomment when updating tests
  # write name, actual

  assert_html_equal expected, actual
end

# Test Notes
# root files must be before any folders.
# Home.md => file at root folder
# docs/sanitization.md => file within folder
context 'file_view' do
  test 'one file' do
    check '1_file', ['0.md']
  end

  test 'one folder' do
    check '1_folder', ['folder0/']
  end

  test 'one file with one folder' do
    check '1_file_1_folder', ['folder0/0.md']
  end

  test 'two files with two folders' do
    check '2_files_2_folders', ['folder0/0.md', 'folder1/1.md']
  end

  test 'two files with two folders and one root file' do
    check '2_files_2_folders_1_root', ['root.md', 'folder0/0.md', 'folder1/1.md']
  end

  test 'nested folders' do
    check 'nested_folders', ['folder0/folder1/folder2/0.md', 'folder0/folder1/folder3/1.md', 'folder4/2.md']
  end
end # context
