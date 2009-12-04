class ForumPost < DomainModel
  belongs_to :forum_forum
  belongs_to :forum_topic
  belongs_to :end_user
  belongs_to :moderated_by, :class_name => 'EndUser'

  validates_presence_of :body, :posted_by, :forum_forum_id, :forum_topic_id

  cached_content :update => [ :forum_forum, :forum_topic ]

  apply_content_filter(:body => :body_html)  do |post|
    { :filter => post.forum_forum.content_filter,
      :folder_id => post.forum_forum.folder_id
    }
  end

  def moderated(end_user)
    self.moderated_at = Time.now
    self.moderated_by = end_user
  end

  def before_validation_on_create
    if self.posted_by.nil? && self.end_user
      self.posted_by = self.end_user.first_name + ' ' + self.end_user.last_name
    end
  end

  def before_update
    if self.changed.include?('body')
      self.edited_at = Time.new
    end
  end

  def before_create
    self.first_post = self.forum_topic.forum_posts.count == 0
    self.posted_at = Time.new
  end

  def after_create
    self.forum_topic.last_post = self
    self.forum_topic.refresh_activity_count
    self.forum_topic.refresh_posts_count
    self.forum_topic.save
  end

  def after_update
    if self.changed.include?('approved')
      self.forum_topic.refresh_posts_count
      self.forum_topic.save
    end
  end

  def after_destroy
    self.forum_topic.refresh_posts_count
    self.forum_topic.save
  end
end
