require  File.expand_path(File.dirname(__FILE__)) + "/../../../../../../spec/spec_helper"

require  File.expand_path(File.dirname(__FILE__)) + '/../../forum_test_helper'

describe Forum::PostsController do

  include ForumTestHelper

  before(:each) do
    mock_editor

    @forum_category = create_forum_category
    @forum_category.save
    @forum = create_forum_forum @forum_category
    @forum.save
    @topic = create_forum_topic_with_end_user @forum, @myself
    @topic.save
  end

  it "should be able to create posts" do

    assert_difference 'ForumPost.count', 1 do
      post 'post', :path => [@forum_category.id, @forum.id, @topic.id], :post => { :body => 'Test Post Body' }
      @post = ForumPost.find(:last)
      response.should redirect_to(:controller => '/forum/posts', :action => 'list', :path => [@forum_category.id, @forum.id, @topic.id])
    end
  end

  it "should be able to edit post" do

    @post = create_forum_post_with_end_user @topic, @myself, 'Change This Body'
    @post.save.should be_true

    assert_difference 'ForumPost.count', 0 do
      post 'post', :path => [@forum_category.id, @forum.id, @topic.id, @post.id], :post => { :body => 'Test Post Body' }
      response.should redirect_to(:controller => '/forum/posts', :action => 'list', :path => [@forum_category.id, @forum.id, @topic.id])
      @post.reload
      @post.body.should == 'Test Post Body'
    end
  end

end


