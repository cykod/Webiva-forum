class ForumPost < DomainModel
  belongs_to :forum_forum
  belongs_to :forum_topic
  belongs_to :end_user
  belongs_to :moderated_by, :class_name => 'EndUser'

  validates_presence_of :body, :subject, :posted_by, :forum_forum_id

  cached_content :update => [ :forum_forum, :forum_topic ]

  apply_content_filter(:body => :body_html)  do |post|
    { :filter => post.forum_forum.content_filter,
      :folder_id => post.forum_forum.folder_id
    }
  end

  named_scope :approved_posts, :conditions => 'approved = 1'

  def moderated(end_user)
    self.moderated_at = Time.now
    self.moderated_by = end_user
  end

  def sticky
    self.forum_topic.sticky
  end

  def sticky=(sticky)
    self.forum_topic.sticky = sticky
  end

  def before_validation_on_create
    if self.posted_by.nil? && self.end_user
      if self.end_user.first_name && self.end_user.last_name
	self.posted_by = self.end_user.first_name + ' ' + self.end_user.last_name
      elsif self.end_user.username
	self.posted_by = self.end_user.username
      else
	self.posted_by = self.end_user.email
      end
    end

    if self.subject.blank? && self.forum_topic
      self.subject = self.forum_topic.default_subject
    end
  end

  def before_update
    if self.changed.include?('body')
      self.edited_at = Time.new
    end
  end

  def before_create
    if self.forum_topic.nil?
      self.create_forum_topic :subject => self.subject, :posted_by => self.posted_by,
	                      :end_user_id => self.end_user_id, :forum_forum_id => self.forum_forum_id
    end

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
