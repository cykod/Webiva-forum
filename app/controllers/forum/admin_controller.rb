class Forum::AdminController < ModuleController
  permit 'editor'
  
  component_info 'Forum', :description => 'Add Forums to your website', 
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

   def self.get_forums_info
      ForumForum.find(:all, :order => 'name',:conditions => 'main_page=1').collect do |forum| 
       {:name => forum.name + " " + "Forum".t ,
         :url => { :controller => '/forum/manage', :action=>'forum', :path => forum.id } ,
         :permission => { :model => forum, :permission => :admin_permission, :base => :forum_manage },
         :icon => 'icons/content/blog.gif' }
     end + [  { :name => 'Manage Forums',
       :url => { :controller => '/forum/manage' },
       :permission => :forum_manage,
       :icon => 'icons/content/blog.gif' } ]
  end
               
   def options
     cms_page_path ['Options','Modules'],'Forum Options'
    
    @options = self.class.module_options(params[:options])
    
    if request.post? && params[:options] && @options.valid?
      Configuration.set_config_model(@options)
      flash[:notice] = "Updated forum module options".t 
      redirect_to :controller => '/modules'
      return
    end    
  
  
  end

  
end
