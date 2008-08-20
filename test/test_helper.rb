ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
#require 'test/unit'
#require 'active_record/fixtures'
#require 'action_controller/test_process'
#require 'action_web_service/test_invoke'
#require 'breakpoint'
require 'wiki_content'
require 'url_generator'

# activate PageObserver
PageObserver.instance

class Test::Unit::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def set_web_property(property, value)
    @web.update_attribute(property, value)
    @page = Page.find(@page.id)
    @wiki.webs[@web.name] = @web
  end

  def setup_wiki_with_30_pages
    ActiveRecord::Base.silence do
      (1..30).each do |i|
        @wiki.write_page('wiki1', "page#{i}", "Test page #{i}\ncategory: test",
                         Time.local(1976, 10, i, 12, 00, 00), Author.new('Dema', '127.0.0.2'),
                         test_renderer)
      end
    end
    @web = Web.find(@web.id)
  end

  def test_renderer(revision = nil)
    PageRenderer.setup_url_generator(StubUrlGenerator.new)
    PageRenderer.new(revision)
  end

  def use_blank_wiki
    Revision.destroy_all
    Page.destroy_all
    Web.destroy_all
  end
end

# This module is to be included in unit tests that involve matching chunks.
# It provides a easy way to test whether a chunk matches a particular string
# and any the values of any fields that should be set after a match.
class ContentStub < String
 include ChunkManager
 def initialize(str)
   super
   init_chunk_manager
 end
 def page_link(*); end
end

module ChunkMatch

 # Asserts a number of tests for the given type and text.
 def match(chunk_type, test_text, expected_chunk_state)
   if chunk_type.respond_to? :pattern
     assert_match(chunk_type.pattern, test_text)
   end

   content = ContentStub.new(test_text)
     chunk_type.apply_to(content)

   # Test if requested parts are correct.
   expected_chunk_state.each_pair do |a_method, expected_value|
     assert content.chunks.last.kind_of?(chunk_type)
     assert_respond_to(content.chunks.last, a_method)
     assert_equal(expected_value, content.chunks.last.send(a_method.to_sym),
       "Wrong #{a_method} value")
   end
 end

 # Asserts that test_text doesn't match the chunk_type
 def no_match(chunk_type, test_text)
   if chunk_type.respond_to? :pattern
     assert_no_match(chunk_type.pattern, test_text)
   end
 end
end

class StubUrlGenerator < AbstractUrlGenerator

 def initialize
   super(:doesnt_need_controller)
 end

 def file_link(mode, name, text, web_name, known_file)
   link = CGI.escape(name)
   case mode
   when :export
     if known_file then %{<a class="existingWikiWord" href="#{link}.html">#{text}</a>}
     else %{<span class="newWikiWord">#{text}</span>} end
   when :publish
     if known_file then %{<a class="existingWikiWord" href="../published/#{link}">#{text}</a>}
     else %{<span class=\"newWikiWord\">#{text}</span>} end
   else
     if known_file
       %{<a class=\"existingWikiWord\" href=\"../file/#{link}\">#{text}</a>}
     else
       %{<span class=\"newWikiWord\">#{text}<a href=\"../file/#{link}\">?</a></span>}
     end
   end
 end

 def page_link(mode, name, text, web_address, known_page)
   link = CGI.escape(name)
   case mode.to_sym
   when :export
     if known_page then %{<a class="existingWikiWord" href="#{link}.html">#{text}</a>}
     else %{<span class="newWikiWord">#{text}</span>} end
   when :publish
     if known_page then %{<a class="existingWikiWord" href="../published/#{link}">#{text}</a>}
     else %{<span class="newWikiWord">#{text}</span>} end
   else
     if known_page
       %{<a class="existingWikiWord" href="../show/#{link}">#{text}</a>}
     else
       %{<span class="newWikiWord">#{text}<a href="../show/#{link}">?</a></span>}
     end
   end
 end

 def pic_link(mode, name, text, web_name, known_pic)
   link = CGI.escape(name)
   case mode.to_sym
   when :export
     if known_pic then %{<img alt="#{text}" src="#{link}" />}
     else %{<img alt="#{text}" src="no image" />} end
   when :publish
     if known_pic then %{<img alt="#{text}" src="#{link}" />}
     else %{<span class="newWikiWord">#{text}</span>} end
   else
     if known_pic then %{<img alt="#{text}" src="../file/#{link}" />}
     else %{<span class="newWikiWord">#{text}<a href="../file/#{link}">?</a></span>} end
   end
 end
end

module Test
 module Unit
   module Assertions
     def assert_success(bypass_body_parsing = false)
       assert_response :success
       unless bypass_body_parsing
         assert_nothing_raised(@response.body) { REXML::Document.new(@response.body) }
       end
     end
   end
 end
end

#ENV['RAILS_ENV'] = 'test'

## Expand the path to environment so that Ruby does not load it multiple times
## File.expand_path can be removed if Ruby 1.9 is in use.
#require File.expand_path(File.dirname(__FILE__) + '/../config/environment')
#require 'application'

#require 'test/unit'
#require 'active_record/fixtures'
#require 'action_controller/test_process'
#require 'action_web_service/test_invoke'
#require 'breakpoint'
#require 'wiki_content'
#require 'url_generator'

#Test::Unit::TestCase.pre_loaded_fixtures = false
#Test::Unit::TestCase.use_transactional_fixtures = true
#Test::Unit::TestCase.use_instantiated_fixtures = false
#Test::Unit::TestCase.fixture_path = File.dirname(__FILE__) + "/fixtures/"

## activate PageObserver
##PageObserver.instance

#class Test::Unit::TestCase
#  def create_fixtures(*table_names)
#    Fixtures.create_fixtures(File.dirname(__FILE__) + "/fixtures", table_names)
#  end

#  # Add more helper methods to be used by all tests here...
##  def set_web_property(property, value)
##    @web.update_attribute(property, value)
##    @page = Page.find(@page.id)
##    @wiki.webs[@web.name] = @web
##  end
##
##  def setup_wiki_with_30_pages
##    ActiveRecord::Base.silence do
##      (1..30).each do |i|
##        @wiki.write_page('wiki1', "page#{i}", "Test page #{i}\ncategory: test",
##                         Time.local(1976, 10, i, 12, 00, 00), Author.new('Dema', '127.0.0.2'),
##                         test_renderer)
##      end
##    end
##    @web = Web.find(@web.id)
##  end

##  def test_renderer(revision = nil)
##    PageRenderer.setup_url_generator(StubUrlGenerator.new)
##    PageRenderer.new(revision)
##  end

##  def use_blank_wiki
##    Revision.destroy_all
##    Page.destroy_all
##    Web.destroy_all
##  end
#end

## This module is to be included in unit tests that involve matching chunks.
## It provides a easy way to test whether a chunk matches a particular string
## and any the values of any fields that should be set after a match.
#class ContentStub < String
#  include ChunkManager
#  def initialize(str)
#    super
#    init_chunk_manager
#  end
#  def page_link(*); end
#end

#module ChunkMatch

#  # Asserts a number of tests for the given type and text.
#  def match(chunk_type, test_text, expected_chunk_state)
#    if chunk_type.respond_to? :pattern
#      assert_match(chunk_type.pattern, test_text)
#    end

#    content = ContentStub.new(test_text)
#      chunk_type.apply_to(content)

#    # Test if requested parts are correct.
#    expected_chunk_state.each_pair do |a_method, expected_value|
#      assert content.chunks.last.kind_of?(chunk_type)
#      assert_respond_to(content.chunks.last, a_method)
#      assert_equal(expected_value, content.chunks.last.send(a_method.to_sym),
#        "Wrong #{a_method} value")
#    end
#  end

#  # Asserts that test_text doesn't match the chunk_type
#  def no_match(chunk_type, test_text)
#    if chunk_type.respond_to? :pattern
#      assert_no_match(chunk_type.pattern, test_text)
#    end
#  end
#end

#class StubUrlGenerator < AbstractUrlGenerator

#  def initialize
#    super(:doesnt_need_controller)
#  end

#  def file_link(mode, name, text, web_name, known_file)
#    link = CGI.escape(name)
#    case mode
#    when :export
#      if known_file then %{<a class="existingWikiWord" href="#{link}.html">#{text}</a>}
#      else %{<span class="newWikiWord">#{text}</span>} end
#    when :publish
#      if known_file then %{<a class="existingWikiWord" href="../published/#{link}">#{text}</a>}
#      else %{<span class=\"newWikiWord\">#{text}</span>} end
#    else
#      if known_file
#        %{<a class=\"existingWikiWord\" href=\"../file/#{link}\">#{text}</a>}
#      else
#        %{<span class=\"newWikiWord\">#{text}<a href=\"../file/#{link}\">?</a></span>}
#      end
#    end
#  end

#  def page_link(mode, name, text, web_address, known_page)
#    link = CGI.escape(name)
#    case mode.to_sym
#    when :export
#      if known_page then %{<a class="existingWikiWord" href="#{link}.html">#{text}</a>}
#      else %{<span class="newWikiWord">#{text}</span>} end
#    when :publish
#      if known_page then %{<a class="existingWikiWord" href="../published/#{link}">#{text}</a>}
#      else %{<span class="newWikiWord">#{text}</span>} end
#    else
#      if known_page
#        %{<a class="existingWikiWord" href="../show/#{link}">#{text}</a>}
#      else
#        %{<span class="newWikiWord">#{text}<a href="../show/#{link}">?</a></span>}
#      end
#    end
#  end

#  def pic_link(mode, name, text, web_name, known_pic)
#    link = CGI.escape(name)
#    case mode.to_sym
#    when :export
#      if known_pic then %{<img alt="#{text}" src="#{link}" />}
#      else %{<img alt="#{text}" src="no image" />} end
#    when :publish
#      if known_pic then %{<img alt="#{text}" src="#{link}" />}
#      else %{<span class="newWikiWord">#{text}</span>} end
#    else
#      if known_pic then %{<img alt="#{text}" src="../file/#{link}" />}
#      else %{<span class="newWikiWord">#{text}<a href="../file/#{link}">?</a></span>} end
#    end
#  end
#end

#module Test
#  module Unit
#    module Assertions
#      def assert_success(bypass_body_parsing = false)
#        assert_response :success
#        unless bypass_body_parsing
#          assert_nothing_raised(@response.body) { REXML::Document.new(@response.body) }
#        end
#      end
#    end
#  end
#end
