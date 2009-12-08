require  File.expand_path(File.dirname(__FILE__)) + "/../../../../../spec/spec_helper"

require  File.expand_path(File.dirname(__FILE__)) + '/../forum_test_helper'

describe ForumForum do

  include ForumTestHelper

  reset_domain_tables :forum_forums,:forum_posts,:forum_categories,:forum_topics

  it 'Initial test data validation' do
    @cat = create_forum_category
    @cat.save.should be_true
  end

  describe 'Detailed forum testing' do

    before(:each) do
      @cat = create_forum_category
      @cat.save
    end

    it "should require a name and content_filter" do
      @forum = ForumForum.new()

      @forum.valid?

      @forum.should have(1).errors_on(:name)
      @forum.should have(1).errors_on(:forum_category_id)
    end

    it "should be able to create a new forum and generate a url" do
      @forum = @cat.forum_forums.build :name => 'Test Forum'
      @forum.save.should be_true

      @forum.url.should == 'test-forum'
    end

    it "should be able to set main_page = true and use ForumCategory.main_forums to fetch" do
      @forum = @cat.forum_forums.build :name => 'Test Forum', :main_page => true
      @forum.save.should be_true

      @main_forums = @cat.main_forums.collect { |row| row.id }
      @main_forums.index(@forum.id).should_not be_nil
    end
  end

end
