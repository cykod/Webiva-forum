require  File.expand_path(File.dirname(__FILE__)) + "/../../../../../spec/spec_helper"

require  File.expand_path(File.dirname(__FILE__)) + '/../forum_test_helper'

describe ForumPost do

  include ForumTestHelper

  reset_domain_tables :forum_forums,:forum_posts,:forum_categories,:forum_topics,:end_users

  it 'Initial test data validation' do
    @user = create_end_user
    @user.save.should be_true
    @cat = create_forum_category
    @cat.save.should be_true
    @forum = create_forum_forum @cat
    @forum.save.should be_true
    @topic = create_forum_topic_with_end_user( @forum, @user )
    @topic.save.should be_true
    @forum.reload
    @forum.forum_topics.size.should == 1
  end

  describe 'Detailed forum post testing' do

    before(:each) do
      @user = create_end_user
      @user.save
      @cat = create_forum_category
      @cat.save
      @forum = create_forum_forum @cat
      @forum.save
      @topic = create_forum_topic_with_end_user( @forum, @user )
      @topic.save
      @forum.reload
    end

    it "should require a body, posted_by, forum_forum_id and forum_topic_id" do
      @post = ForumPost.new()

      @post.valid?

      @post.should have(1).errors_on(:body)
      @post.should have(1).errors_on(:posted_by)
      @post.should have(1).errors_on(:forum_forum_id)
      @post.should have(1).errors_on(:forum_topic_id)
    end

    it "should set posted_by to end_user.username" do
      @post = @topic.build_post :body => 'test post', :end_user => @user
      @post.save.should be_true
      @post.posted_by.should == (@user.first_name + ' ' + @user.last_name)
    end

    it "should increment forum_posts_count" do
      @post = @topic.build_post :body => 'test post', :end_user => @user
      @post.save.should be_true
      @topic.reload
      @topic.forum_posts.size.should == 1

      @post = @topic.build_post :body => 'test post', :posted_by => 'Test User2'
      @post.save.should be_true
      @topic.reload
      @topic.forum_posts.size.should == 2
    end

    it "should be able to fetch first post" do
      @first_post = @topic.build_post :body => 'test post', :end_user => @user
      @first_post.save.should be_true
      @topic.first_post.should == @first_post

      @post = @topic.build_post :body => '2nd test post', :posted_by => 'user2'
      @post.save.should be_true

      @topic.first_post.should == @first_post
    end

    it "should be able to fetch last post" do
      @post = @topic.build_post :body => 'test post', :end_user => @user
      @post.save.should be_true
      @topic.reload
      @topic.last_post.should == @post

      @post = @topic.build_post :body => '2nd test post', :posted_by => 'user2'
      @post.save.should be_true
      @topic.reload
      @topic.last_post.should == @post
    end

    it "should increment forum_posts_count for approved posts only" do
      @post = create_forum_post_with_end_user(@topic, @user)
      @post.save.should be_true
      @topic.reload
      @topic.forum_posts.size.should == 1
      @topic.activity_count.should == 1

      @post = create_forum_post(@topic, 'test post', {:posted_by => 'Test User2'})
      @post.save.should be_true
      @topic.reload
      @topic.forum_posts.size.should == 2
      @topic.activity_count.should == 2

      @post.update_attributes :approved => false
      @topic.reload
      @topic.forum_posts.size.should == 1
      @topic.activity_count.should == 2
    end

    it "should increment activity_count for new posts in last 2 days" do
      @post = create_forum_post_with_end_user(@topic, @user)
      @post.save.should be_true
      @topic.reload
      @topic.forum_posts.size.should == 1
      @topic.activity_count.should == 1

      @post.update_attributes :posted_at => 3.days.ago

      @post = create_forum_post(@topic, 'test post', {:posted_by => 'Test User2'})
      @post.save.should be_true
      @topic.reload
      @topic.forum_posts.size.should == 2
      @topic.activity_count.should == 1

      @post.update_attributes :posted_at => 1.days.ago

      @post = create_forum_post(@topic, 'test post', {:posted_by => 'Test User3'})
      @post.save.should be_true
      @topic.reload
      @topic.forum_posts.size.should == 3
      @topic.activity_count.should == 2
    end

    it "should only update edited_at if body changes" do
      body = 'test post'
      @post = create_forum_post(@topic, body, {:posted_by => 'Test User3'})
      @post.save.should be_true
      @post.edited_at.should == nil
      @topic.reload

      @post.update_attributes :body => body
      @post.edited_at.should == nil

      @post.update_attributes :body => 'updated test post'
      @post.edited_at.should_not == nil
    end
  end
end
