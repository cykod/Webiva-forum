class ForumTopic < DomainModel

  cached_content :update => [ :forum_forum ]
  
  belongs_to :forum_forum

  has_many :forum_posts

  belongs_to :last_post_id
end
