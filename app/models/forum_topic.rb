class ForumTopic < DomainModel
  belongs_to :forum_forum, :counter_cache => true
  belongs_to :end_user

  has_many :forum_posts, :dependent => :destroy
  has_many :forum_subscriptions, :dependent => :destroy

  validates_presence_of :subject, :forum_forum_id, :posted_by

  validates_numericality_of :sticky, :only_integer => true

  cached_content :update => [ :forum_forum ]
  
  belongs_to :last_post, :class_name => 'ForumPost'

  named_scope :sticky_topics, :conditions => 'forum_topics.sticky > 0'
  named_scope :order_by_recent_topics, lambda { |from| {:order => sanitize_sql_for_conditions(['if(`forum_topics`.last_posted_at > ?, `forum_topics`.activity_count, 0) DESC, `forum_topics`.last_posted_at DESC', from]) }}
  named_scope :topics_for_content, lambda { |type, id| {:conditions => ['`forum_topics`.content_type = ? and `forum_topics`.content_id = ?', type, id]} }

  def build_post(options={})
    self.forum_posts.build( {:forum_forum_id => self.forum_forum_id}.merge(options) )
  end

  def build_subscription(user)
    self.forum_subscriptions.build( :end_user => user, :forum_forum_id => self.forum_forum_id )
  end

  def first_post
    @first_post ||= self.forum_posts.find_by_first_post(true)
  end

  def body
    return @body if @body
    @body = self.first_post ? self.first_post.body : nil
  end

  def body_html
    self.first_post ? self.first_post.body_html : nil
  end

  def body=(body)
    @body = body
  end

  def default_subject
    if self.forum_posts.count == 0
      self.subject
    else
      'Re: %s' / self.subject
    end
  end

  def recent_activity_count(from=nil)
    from ||= 2.days.ago
    self.updated_at >= from ? self.activity_count : 0
  end

  def calculate_activity_count(from=nil)
    from ||= 2.days.ago
    self.forum_posts.count( :conditions => ['forum_posts.posted_at >= ?', from] )
  end

  def refresh_activity_count(from=nil)
    self.activity_count = calculate_activity_count(from)
  end

  def refresh_posts_count
    self.forum_posts_count = self.forum_posts.approved_posts.count
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
  end

  def after_save
    if @body
      post = self.first_post
      if ! post
	post = self.build_post :subject => self.subject, :end_user => self.end_user, :posted_by => self.posted_by
      end
      post.body = @body
      post.save
      @body = nil
    end
  end

  def subscribe?(end_user)
    end_user.id ? true : false
  end
end
