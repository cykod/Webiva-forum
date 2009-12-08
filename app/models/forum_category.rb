

class ForumCategory < DomainModel

  @@built_in_user_filters = [ ['Markdown Safe','markdown_safe'],
                              ['Textile Safe','textfile_safe']
                              ]

  has_many :forum_forums, :dependent => :destroy

  validates_presence_of :name
  validates_presence_of :content_filter

  cached_content :identifier => :url

  validates_inclusion_of :content_filter, :in => @@built_in_user_filters.map {|disp, value| value}

  validates_numericality_of :weight, :only_integer => true
  validates_numericality_of :file_size_limit, :only_integer => true, :allow_nil => true

  include SiteAuthorizationEngine::Target
  access_control :admin_permission
  access_control :post_permission

  def self.filter_user_options
    @@built_in_user_filters.map { |elm| [ elm[0].t, elm[1] ] }
  end

  def before_validation
    self.url = generate_url(:url,self.name) if self.url.blank?
  end

  def main_forums
    @forums ||= self.forum_forums.find(:all, :conditions => 'main_page = 1', :order => 'name')
  end

end
