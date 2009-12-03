class ForumSubscription < DomainModel
  belongs_to :end_user
  belongs_to :forum_topic
  belongs_to :forum_forum

  named_scope( :user_subscriptions, Proc.new { |user|
    {
      :conditions => { :end_user_id => user.id }
    }
  })

end
