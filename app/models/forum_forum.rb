class ForumForum < DomainModel

  validates_presence_of :name, :forum_category_id

  cached_content :identifier => :url

  content_node_type :forum_forum, "ForumPost", :content_name => :name, :title_field => :subject

  belongs_to :forum_category
  has_many :forum_topics, :dependent => :destroy
  has_many :forum_posts
  has_many :forum_subscriptions

  belongs_to :image, :class_name => 'DomainFile'

  named_scope :main_forums, :conditions => 'main_page = 1'

  def before_validation
    self.url = generate_url(:url,self.name) if self.url.blank?
  end

  def content_filter
    self.forum_category.content_filter
  end

  def folder_id
    self.forum_category.folder_id
  end

  def allow_anonymous_posting
    self.forum_category.allow_anonymous_posting
  end

  def allow_attachments
    self.forum_category.allow_attachments
  end
end
