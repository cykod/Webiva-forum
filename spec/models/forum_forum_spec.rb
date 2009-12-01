require  File.expand_path(File.dirname(__FILE__)) + "/../../../../../spec/spec_helper"

describe ForumForum do

  reset_domain_tables :forum_forums,:forum_posts,:forum_categories,:forum_topics


  it "should require a name and content_filter" do

    @forum = ForumForum.new()

    @forum.valid?

    @forum.should have(1).errors_on(:name)
    @forum.should have(1).errors_on(:forum_category_id)

  end

  it "should be able to create a new forum and generate a url" do
    @cat = ForumCategory.new(:content_filter => 'markdown')

    @cat.save.should be_true
    @forum = ForumForum.new(:name => 'Test Forum',:forum_category => @cat )

    @forum.save.should be_true

    @forum.url.should == 'test-forum'
  end

end
