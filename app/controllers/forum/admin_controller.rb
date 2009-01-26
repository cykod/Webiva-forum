class Forum::AdminController < ModuleController
  permit 'editor'
  
  component_info 'Forum', :description => 'Add Forums', 
                              :access => :private
                              
  content_model :forums
  
  content_action  'Create a new Forum', { :controller => '/forum/admin', :action => 'create' } 

  register_permission_category :forum, "Forum" ,"Permissions for Writing to and Managing Forums"
  
  register_permissions :forum, [[ :manage, 'Forum Management', 'Can Manage forums and posts' ], 
                                [ :config, 'Forum Configuration', 'Can Create, Delete and Configure Forums'],
                                [ :post, 'Can Post', 'Can Post to Forums'],
                                [ :search, 'Can Search', 'Can Search Forums' ]
                             ]

  private
  def get_module
    @mod = SiteModule.get_module('forum')
    
    @mod.options = {} unless @mod.options.is_a?(Hash)
  end
                     
  public     

   def self.get_forum_info
      Forum.find(:all, :order => 'name').collect do |forum| 
          {:name => forum.name + " " + "Forum".t ,:url => { :controller => '/forum/manage', :path => blog.id } ,:permission => 'forum_manage', :icon => 'icons/content/blog.gif' }
      end 
  end
               
#  def options
#    cms_page_info [ ["Options",url_for(:controller => '/options') ], ["Modules",url_for(:controller => "/modules")], "Blog Module Options "], "options"
#    get_module
#    
#    options = @mod.options 
#    
#  end

  def create
    cms_page_info [ ["Content",url_for(:controller => '/content') ], "Create a new Forum"], "content"
    get_module
    
    @forum = Forum.new(params[:forum])

    if(request.post? && params[:forum])
      if(@forum.save)
        redirect_to :controller => '/forum/manage', :path => @blog.id
        return 
      end
    end

  end
  
end
