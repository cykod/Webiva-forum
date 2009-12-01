class ForumForum < DomainModel

  validates_presence_of :name,:forum_category_id

  cached_content :identifier => :url

  content_node_type :forum, "Forum::ForumPost", :content_name => :name, :title_field => :subject

  include SiteAuthorizationEngine::Target
  access_control :admin_permission
  access_control :post_permission

  belongs_to :forum_category
  has_many :forum_topics
  has_many :forum_posts

  def before_validation
    self.url = generate_url(:url,self.name)
  end

  def content_filter
    self.forum_category.content_filter
  end

  def folder_id
    self.forum_category.folder_id
    
  end
end
