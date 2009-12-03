class ForumPost < DomainModel
  after_destroy :after_destroy_post
  after_create :after_create_post
  before_create :before_create_post
  before_save :before_save_post
  after_update :after_update_post

  belongs_to :forum_forum
  belongs_to :forum_topic
  belongs_to :end_user

  validates_presence_of :body, :posted_by

  cached_content :update => [ :forum_forum, :forum_topic ]

  apply_content_filter(:body => :body_html)  do |post|
    { :filter => post.forum_forum.content_filter,
      :folder_id => post.forum_forum.folder_id
    }
  end

  def moderated(end_user)
    self.moderated_at = Time.now
    self.moderated_by_id = end_user.id
  end

  def before_save_post
    if self.id && self.changed.include?('body')
      self.edited_at = Time.new
    end
  end

  def before_create_post
    self.first_post = self.forum_topic.forum_posts.count == 0
    self.posted_at = Time.new
  end

  def after_create_post
    self.forum_topic.last_post = self
    self.forum_topic.refresh_activity_count
    self.forum_topic.refresh_posts_count
    self.forum_topic.save
  end

  def after_update_post
    if self.changed.include?('approved')
      self.forum_topic.refresh_posts_count
      self.forum_topic.save
    end
  end

  def after_destroy_post
    self.forum_topic.refresh_posts_count
  end
end
