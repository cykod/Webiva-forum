class ForumTopic < DomainModel
  belongs_to :forum_forum, :counter_cache => true
  belongs_to :end_user

  has_many :forum_posts
  has_many :forum_subscriptions

  validates_presence_of :subject

  cached_content :update => [ :forum_forum ]
  
  belongs_to :last_post, :class_name => 'ForumPost'

  def build_post(options={})
    self.forum_posts.build( {:forum_forum_id => self.forum_forum_id}.merge(options) )
  end

  def first_post
    self.forum_posts.find_by_first_post(true)
  end

  def default_subject
    if self.forum_posts.count == 0
      self.subject
    else
      'Re: %s' / self.subject
    end
  end

  def calculate_activity_count(from=nil)
    from ||= 2.days.ago
    self.forum_posts.count( :conditions => ['posted_at >= ?', from] )
  end

  def refresh_activity_count
    self.activity_count = calculate_activity_count
  end

  def refresh_posts_count
    self.forum_posts_count = self.forum_posts.count(:conditions => 'approved = 1')
  end
end
