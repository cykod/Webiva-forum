class ForumPost < DomainModel

  cached_content :update => [ :forum_forum, :forum_topic ]

  apply_content_filter(:body => :body_html)  do |post|
    { :filter => post.forum_forum.content_filter,
      :folder_id => post.forum_forum.folder_id
    }
  end

  belongs_to :forum_forum
  belongs_to :forum_topic
end
