require  File.expand_path(File.dirname(__FILE__)) + "/../../../../../../spec/spec_helper"

require  File.expand_path(File.dirname(__FILE__)) + '/../../forum_test_helper'

describe Forum::TopicsController do

  include ForumTestHelper

  before(:each) do
    @forum_category = create_forum_category
    @forum_category.save
    @forum = create_forum_forum @forum_category
    @forum.save
  end

  it "should be able to create topics" do
    mock_editor

    assert_difference 'ForumTopic.count', 1 do
      post 'topic', :path => [@forum_category.id, @forum.id], :topic => { :subject => 'Test Subject', :forum_forum_id => @forum.id, :end_user_id => @myself.id }
      @topic = ForumTopic.find(:last)
      response.should redirect_to(:controller => '/forum/posts', :action => 'list', :path => [@forum_category.id, @forum.id, @topic.id])
    end
  end

  it "should be able to edit topic" do
    mock_editor

    @topic = create_forum_topic_with_end_user @forum, @myself, 'Change This Subject'
    @topic.save.should be_true

    assert_difference 'ForumTopic.count', 0 do
      post 'topic', :path => [@forum_category.id, @forum.id, @topic.id], :topic => { :subject => 'Test Subject' }
      response.should redirect_to(:controller => '/forum/posts', :action => 'list', :path => [@forum_category.id, @forum.id, @topic.id])
      @topic.reload
      @topic.subject.should == 'Test Subject'
    end
  end

  it "should be able to delete a topic" do
    mock_editor

    @topic = create_forum_topic_with_end_user @forum, @myself
    @topic.save.should be_true

    assert_difference 'ForumTopic.count', -1 do
      post 'delete', :path => [@forum_category.id, @forum.id, @topic.id], :destroy => 'yes'
      response.should redirect_to(:controller => '/forum/topics', :action => 'list', :path => [@forum_category.id, @forum.id])
    end
  end

end


