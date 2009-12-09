require  File.expand_path(File.dirname(__FILE__)) + "/../../../../../../spec/spec_helper"

require  File.expand_path(File.dirname(__FILE__)) + '/../../forum_test_helper'

describe Forum::PageRenderer, :type => :controller do
  include ForumTestHelper
  controller_name :page
  
  integrate_views

  reset_domain_tables :end_user,:forum_forums,:forum_posts,:forum_categories,:forum_topics

  it 'Initial test data validation' do
    @user = create_end_user
    @user.save
    @cat = create_forum_category
    @cat.save.should be_true
    @forum = create_forum_forum @cat
    @forum.save.should be_true
    @topic = create_forum_topic_with_end_user( @forum, @user )
    @topic.save.should be_true
    @forum.reload
    @forum.forum_topics.size.should == 1
    @post = create_forum_post_with_end_user(@topic, @user)
    @post.save.should be_true
    @topic.reload
    @topic.forum_posts.size.should == 1
  end

  describe "Page Render" do
    def generate_page_renderer(paragraph, options={}, inputs={})
      @rnd = build_renderer('/page', '/forum/page/' + paragraph, options, inputs)
    end

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
      @post = create_forum_post_with_end_user(@topic, @user)
      @post.save
      @topic.reload
    end

    it "should be able to list categories" do
      @rnd = generate_page_renderer('categories')
      @rnd.should_render_feature('forum_page_categories')
      
      ForumCategory.should_receive(:paginate)
      renderer_get @rnd
    end

    it "should be able to list forums for a category url" do
      options = { :forum_category_id => nil }
      inputs = { :input => [:url, @cat.url] }
      @rnd = generate_page_renderer('list', options, inputs)
      @rnd.should_render_feature('forum_page_list')

      ForumCategory.should_receive(:find_by_url).and_return(@cat)
      ForumForum.should_receive(:paginate)
      renderer_get @rnd
    end

    it "should be able to list forums for a category" do
      options = { :forum_category_id => @cat.id }
      @rnd = generate_page_renderer('list', options)
      @rnd.should_render_feature('forum_page_list')

      ForumForum.should_receive(:paginate)
      renderer_get @rnd
    end

    it "should be able to list forums for a category in editor mode" do
      @rnd = generate_page_renderer('list')
      @rnd.should_receive(:editor?).and_return(true)
      @rnd.should_render_feature('forum_page_list')

      ForumForum.should_receive(:paginate)
      renderer_get @rnd
    end

    it "should be able to list topics for forum in editor mode" do
      @rnd = generate_page_renderer('forum')
      @rnd.should_receive(:editor?).and_return(true)
      @rnd.should_render_feature('forum_page_forum')

      ForumTopic.should_receive(:paginate)
      renderer_get @rnd

      options = { :forum_forum_id => @forum.id }
      @rnd = generate_page_renderer('forum', options)
      @rnd.should_receive(:editor?).and_return(true)
      @rnd.should_render_feature('forum_page_forum')

      ForumForum.should_receive(:find_by_id).and_return(@forum)
      ForumTopic.should_receive(:paginate)
      renderer_get @rnd
    end

    it "should be able to list topics for a forum url" do
      options = { :forum_forum_id => nil }
      inputs = { :forum => [:url, @forum.url] }
      @rnd = generate_page_renderer('forum', options, inputs)
      @rnd.should_render_feature('forum_page_forum')

      ForumForum.should_receive(:find_by_url).and_return(@forum)
      ForumTopic.should_receive(:paginate)
      renderer_get @rnd
    end

    it "should be able to list topics for a forum id" do
      options = { :forum_forum_id => @forum.id }
      @rnd = generate_page_renderer('forum', options)
      @rnd.should_render_feature('forum_page_forum')

      ForumForum.should_receive(:find).and_return(@forum)
      ForumTopic.should_receive(:paginate)
      renderer_get @rnd
    end

    it "should not list topics for a forum url if a topic id is specified" do
      options = { :forum_forum_id => nil }
      inputs = { :forum => [:url, @forum.url], :topic => [:id, @topic.id] }
      @rnd = generate_page_renderer('forum', options, inputs)
      @rnd.should_render_feature('forum_page_forum')

      ForumForum.should_receive(:find_by_url).and_return(@forum)
      ForumTopic.should_receive(:find_by_id).and_return(@topic)
      ForumTopic.should_not_receive(:paginate)
      renderer_get @rnd
    end

    it "should be able to list posts for a topic in editor mode" do
      @rnd = generate_page_renderer('topic')
      @rnd.should_receive(:editor?).and_return(true)
      @rnd.should_render_feature('forum_page_topic')

      ForumPost.should_receive(:paginate)
      renderer_get @rnd

      options = { :forum_forum_id => @forum.id }
      @rnd = generate_page_renderer('topic', options)
      @rnd.should_receive(:editor?).and_return(true)
      @rnd.should_render_feature('forum_page_topic')

      ForumForum.should_receive(:find_by_id).and_return(@forum)
      ForumPost.should_receive(:paginate)
      renderer_get @rnd
    end

    it "should be able to list posts for a topic in given a forum url and a topic id" do
      options = {}
      inputs = { :forum => [:url, @forum.url], :topic => [:id, @topic.id] }
      @rnd = generate_page_renderer('topic', options, inputs)
      @rnd.should_render_feature('forum_page_topic')

      
      ForumForum.should_receive(:find_by_url).and_return(@forum)
      ForumTopic.should_receive(:find_by_id).and_return(@topic)
      ForumPost.should_receive(:paginate)
      renderer_get @rnd
    end

    it "should be able to list posts for a specific forum given a topic id" do
      options = { :forum_forum_id => @forum.id }
      inputs = { :topic => [:id, @topic.id] }
      @rnd = generate_page_renderer('topic', options, inputs)
      @rnd.should_render_feature('forum_page_topic')

      
      ForumForum.should_receive(:find).and_return(@forum)
      ForumTopic.should_receive(:find_by_id).and_return(@topic)
      ForumPost.should_receive(:paginate)
      renderer_get @rnd
    end

    it "should be able to display new post form editor mode" do
      mock_user

      @rnd = generate_page_renderer('new_post')
      @rnd.should_receive(:editor?).and_return(true)
      @rnd.should_render_feature('forum_page_new_post')

      renderer_get @rnd

      options = { :forum_forum_id => @forum.id }
      @rnd = generate_page_renderer('new_post', options)
      @rnd.should_receive(:editor?).and_return(true)
      @rnd.should_render_feature('forum_page_new_post')

      ForumForum.should_receive(:find_by_id).and_return(@forum)
      renderer_get @rnd
    end

    it "should be able to display new topic form for a forum" do
      mock_user

      options = {}
      inputs = { :input => [:forum_path, @forum.url] } 
      @rnd = generate_page_renderer('new_post', options, inputs)
      @rnd.should_render_feature('forum_page_new_post')

      ForumForum.should_receive(:find_by_url).and_return(@forum)
      @forum.should_receive(:allowed_to_create_topic?).and_return(true)
      renderer_get @rnd

      options = { :forum_forum_id => @forum.id }
      inputs = {} 
      @rnd = generate_page_renderer('new_post', options, inputs)
      @rnd.should_render_feature('forum_page_new_post')

      ForumForum.should_receive(:find).and_return(@forum)
      @forum.should_receive(:allowed_to_create_topic?).and_return(true)
      renderer_get @rnd

      options = {}
      inputs = { :input => [:forum, @forum] } 
      @rnd = generate_page_renderer('new_post', options, inputs)
      @rnd.should_render_feature('forum_page_new_post')

      @forum.should_receive(:allowed_to_create_topic?).and_return(true)
      renderer_get @rnd
    end

    it "should be able to display new post form for a topic" do
      mock_user

      options = {}
      inputs = { :input => [:forum_path, @forum.url], :topic => [:id, @topic.id] } 
      @rnd = generate_page_renderer('new_post', options, inputs)
      @rnd.should_render_feature('forum_page_new_post')

      ForumForum.should_receive(:find_by_url).and_return(@forum)
      ForumTopic.should_receive(:find).and_return(@topic)
      @forum.should_receive(:allowed_to_create_post?).and_return(true)
      renderer_get @rnd

      options = {}
      inputs = { :input => [:topic, @topic] } 
      @rnd = generate_page_renderer('new_post', options, inputs)
      @rnd.should_render_feature('forum_page_new_post')

      @topic.should_receive(:forum_forum).and_return(@forum)
      @forum.should_receive(:allowed_to_create_post?).and_return(true)
      renderer_get @rnd
    end

    it "should be able to create a new topic" do
      mock_user

      @topic_page_node = SiteNode.create(:node_type => 'P', :title => 'topic')
      options = {:forum_page_id => @topic_page_node.id}
      inputs = { :input => [:forum, @forum] } 
      @rnd = generate_page_renderer('new_post', options, inputs)

      @forum.should_receive(:allowed_to_create_topic?).and_return(true)
      renderer_post @rnd, { :post => {:body => 'My Test Post', :subject => 'My Test Subject'} }

      @post = ForumPost.find(:first, :order => 'id DESC')
      @post.body.should == 'My Test Post'
      @post.subject.should == 'My Test Subject'
      @post.forum_topic.subject.should == 'My Test Subject'

      @rnd.should redirect_paragraph('/topic/' + @forum.url + '/' + @post.forum_topic.id.to_s)
    end

    it "should be able to create a new post" do
      mock_user

      @topic_page_node = SiteNode.create(:node_type => 'P', :title => 'topic')
      options = {:forum_page_id => @topic_page_node.id}
      inputs = { :input => [:topic, @topic] } 
      @rnd = generate_page_renderer('new_post', options, inputs)

      @topic.should_receive(:forum_forum).and_return(@forum)
      @forum.should_receive(:allowed_to_create_post?).and_return(true)
      renderer_post @rnd, { :post => {:body => 'My Test Post'} }

      @post = ForumPost.find(:first, :order => 'id DESC')
      @post.body.should == 'My Test Post'
      @post.subject.should == @topic.default_subject

      @rnd.should redirect_paragraph('/topic/' + @forum.url + '/' + @post.forum_topic.id.to_s)
    end

    it "should be able to display recent topics form editor mode" do
      @rnd = generate_page_renderer('recent')
      @rnd.should_receive(:editor?).and_return(true)
      @rnd.should_render_feature('forum_page_recent')

      ForumTopic.should_receive(:paginate)
      renderer_get @rnd

      options = { :forum_category_id => @cat.id }
      @rnd = generate_page_renderer('recent', options)
      @rnd.should_receive(:editor?).and_return(true)
      @rnd.should_render_feature('forum_page_recent')

      ForumCategory.should_receive(:find_by_id).and_return(@cat)
      ForumTopic.should_receive(:paginate)
      renderer_get @rnd

      options = { :forum_forum_id => @forum.id }
      @rnd = generate_page_renderer('recent', options)
      @rnd.should_receive(:editor?).and_return(true)
      @rnd.should_render_feature('forum_page_recent')

      ForumForum.should_receive(:find_by_id).and_return(@forum)
      @forum.should_receive(:forum_category).and_return(@cat)
      ForumTopic.should_receive(:paginate)
      renderer_get @rnd
    end

    it "should be able to display recent topics for category" do
      options = { :forum_category_id => @cat.id }
      inputs = {}
      @rnd = generate_page_renderer('recent', options, inputs)
      @rnd.should_render_feature('forum_page_recent')

      ForumCategory.should_receive(:find).and_return(@cat)
      ForumTopic.should_receive(:paginate)
      renderer_get @rnd

      options = {}
      inputs = { :input => [:category, @cat] }
      @rnd = generate_page_renderer('recent', options, inputs)
      @rnd.should_render_feature('forum_page_recent')

      ForumTopic.should_receive(:paginate)
      renderer_get @rnd

      options = {}
      inputs = { :input => [:category_path, @cat.url] }
      @rnd = generate_page_renderer('recent', options, inputs)
      @rnd.should_render_feature('forum_page_recent')

      ForumCategory.should_receive(:find_by_url).and_return(@cat)
      ForumTopic.should_receive(:paginate)
      renderer_get @rnd
    end

    it "should be able to display recent topics for forum" do
      options = { :forum_forum_id => @forum.id }
      inputs = {}
      @rnd = generate_page_renderer('recent', options, inputs)
      @rnd.should_render_feature('forum_page_recent')

      ForumForum.should_receive(:find).and_return(@forum)
      ForumTopic.should_receive(:paginate)
      renderer_get @rnd

      options = {}
      inputs = { :input => [:forum, @forum] }
      @rnd = generate_page_renderer('recent', options, inputs)
      @rnd.should_render_feature('forum_page_recent')

      ForumTopic.should_receive(:paginate)
      renderer_get @rnd

      options = {}
      inputs = { :input => [:category_path, @cat.url], :forum => [:url, @forum.url] }
      @rnd = generate_page_renderer('recent', options, inputs)
      @rnd.should_render_feature('forum_page_recent')

      ForumCategory.should_receive(:find_by_url).and_return(@cat)
      @cat.forum_forums.should_receive(:find_by_url).and_return(@forum)
      ForumTopic.should_receive(:paginate)
      renderer_get @rnd
    end
  end
end
