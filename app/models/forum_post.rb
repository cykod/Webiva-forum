class ForumPost < DomainModel
  belongs_to :forum_topic
  belongs_to :end_user

  validates_presence_of :posted_by
end
