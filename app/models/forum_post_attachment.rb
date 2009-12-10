
class ForumPostAttachment < DomainModel
  belongs_to :end_user
  belongs_to :forum_post
  belongs_to :domain_file

  validates_presence_of :end_user_id, :forum_post_id, :domain_file_id

  named_scope( :user_attachments, Proc.new { |user|
    {
      :conditions => { :end_user_id => user.id }
    }
  })

end
