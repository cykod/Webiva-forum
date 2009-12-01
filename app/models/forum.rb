class Forum < DomainModel
  has_many :forum_topics
  has_many :forum_subscriptions

  acts_as_tree :order => 'name'

  has_options :markup_language, [['Markdown','markdown'],['Textile','textile']]

  validates_presence_of :name
end
