class Forum::AdminController < ModuleController
  before_filter :find_forum_category, :only => 'configure'

  helper 'forum/path'

  permit 'forum_config'
  
  component_info 'Forum', :description => 'Add Forums to your website', 
                          :access => :private
                              
  content_model :forums
  
  content_action  'Create a new Forum Category', { :controller => '/forum/admin', :action => 'create' } 

  register_permission_category :forum, "Forum" ,"Permissions for Writing to and Managing Forums"
  
  register_permissions :forum, [[ :manage, 'Forum Management', 'Can Manage forums and posts' ], 
                                [ :config, 'Forum Configuration', 'Can Create, Delete and Configure Forums'],
                                [ :post, 'Can Post', 'Can Post to Forums'],
                                [ :search, 'Can Search', 'Can Search Forums' ]
                             ]

  cms_admin_paths "options",
                  'Content' => { :controller => '/content' },
                  'Options' =>   { :controller => '/options' },
                  'Modules' =>  { :controller => '/modules' },
                  'Forum Options' => { :action => 'options' }

  public     

  def self.get_forums_info
    ForumCategory.find(:all, :order => 'weight, name').collect do |category| 
      {:name => "%s Forums" / category.name,
	:url => { :controller => '/forum/manage', :action=>'category', :path => category.id } ,
	:permission => { :model => category, :permission => :admin_permission, :base => :forum_manage },
	:icon => 'icons/content/blog.gif' }
    end
  end
  
  def options
    cms_page_path ['Options','Modules'], 'Forum Options'
    
    @options = self.class.module_options(params[:options])
    
    if request.post? && @options.valid?
      Configuration.set_config_model(@options)
      flash[:notice] = "Updated forum module options".t 
      redirect_to :controller => '/modules'
      return
    end    
  end

  def create
    cms_page_path ['Content'], 'Create a new Forum Category'
    
    @forum_category = ForumCategory.new(params[:forum_category])

    if(request.post? && params[:forum_category])
      if(@forum_category.save)
        redirect_to forum_category_url_for
        return 
      end
    end

  end

  def configure
    cms_page_path ['Content'], ['%s Forums', forum_category_url_for, @forum_category.name]
    
    if(request.post? && @forum_category && params[:forum_category])
      if(@forum_category.update_attributes(params[:forum_category]))
        redirect_to forum_category_url_for
        return 
      end
    end
  end

  def self.module_options(vals=nil)
    Configuration.get_config_model(Options,vals)
  end
  

  class Options < HashModel
    
    
  end
  
  module AdminModule
    include Forum::PathHelper

    def find_forum_category
      @forum_category ||= ForumCategory.find(params[:path][0])
    end
  end

  include AdminModule
end
