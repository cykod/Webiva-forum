class ForumTopic < DomainModel
  belongs_to :forum
  belongs_to :end_user

  has_many :forum_posts
  has_many :forum_subscriptions

  validates_presence_of :subject
end
