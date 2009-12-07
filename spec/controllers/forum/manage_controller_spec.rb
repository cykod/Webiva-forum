require  File.expand_path(File.dirname(__FILE__)) + "/../../../../../../spec/spec_helper"

require  File.expand_path(File.dirname(__FILE__)) + '/../../forum_test_helper'

describe Forum::ManageController do

  include ForumTestHelper

  it "should be able to create forums" do
    mock_editor

    @forum_category = create_forum_category
    @forum_category.save.should be_true

    assert_difference 'ForumForum.count', 1 do
      post 'forum', :path => [@forum_category.id], :forum => { :name => 'Test Forum', :forum_category_id => @forum_category.id }
      @forum = ForumForum.find(:last)
      response.should redirect_to(:controller => '/forum/topics', :action => 'list', :path => [@forum_category.id, @forum.id])
    end
  end

  it "should be able to edit forum" do
    mock_editor

    @forum_category = create_forum_category
    @forum_category.save.should be_true

    @forum = create_forum_forum @forum_category, 'Change This Forum Name'
    @forum.save.should be_true

    assert_difference 'ForumForum.count', 0 do
      post 'forum', :path => [@forum_category.id, @forum.id], :forum => { :name => 'Test Forum' }
      response.should redirect_to(:controller => '/forum/topics', :action => 'list', :path => [@forum_category.id, @forum.id])
      @forum.reload
      @forum.name.should == 'Test Forum'
    end
  end

  it "should be able to delete a forum" do
    mock_editor

    @forum_category = create_forum_category
    @forum_category.save.should be_true

    @forum = create_forum_forum @forum_category
    @forum.save.should be_true

    assert_difference 'ForumForum.count', -1 do
      post 'delete', :path => [@forum_category.id, @forum.id], :destroy => 'yes'
      response.should redirect_to(:controller => '/forum/manage', :action => 'category', :path => @forum_category.id)
    end
  end

end


