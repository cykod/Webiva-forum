

class Forum::TopicsController < ModuleController
  before_filter :find_forum_category, :find_forum, :find_topic

  helper 'forum/path'

  permit 'forum_manage'

  component_info 'Forum'

  # need to include 
  include ActiveTable::Controller
  active_table :topic_table,
                ForumTopic,
                [ hdr(:icon, '', :width=>10),
                  hdr(:string, 'forum_topics.subject', :label => 'Topics'),
                  hdr(:string, 'forum_topics.posted_by'),
                  hdr(:number, 'forum_topics.forum_posts_count'),
                  hdr(:number, 'forum_topics.activity_count'),
                  hdr(:boolean, 'forum_topics.sticky'),
                  :updated_at,
                  :created_at
                ]

  cms_admin_paths 'content', 
                  'Content' => { :controller => '/content' }

  def list
    topics_path '%s Forum' / @forum.name
    topic_table(false)
  end

  def topic_table(display=true)
    if(request.post? && params[:table_action] && params[:topic].is_a?(Hash)) 
      
      case params[:table_action]
      when 'delete':
	  params[:topic].each do |entry_id,val|
          ForumTopic.destroy(entry_id.to_i)
	end
      end
    end
    
    @active_table_output = topic_table_generate params, :order => 'forum_topics.updated_at DESC', :conditions => ['forum_topics.forum_forum_id = ?',@forum.id ]

    render :partial => 'topic_table' if display
  end

  def topic
    if @topic.nil?
      @topic = @forum.forum_topics.build
      topics_path 'Create a new Topic'.t
    else
      topics_path @topic.subject, posts_list_url_for
    end

    if request.post? && params[:topic]
      if @topic.update_attributes(params[:topic])
	redirect_to posts_list_url_for
      end
    end
  end

  private
  module TopicsModule
    include  Forum::ManageController::ForumModule

    def find_topic
      @topic ||= @forum.forum_topics.find(params[:path][2]) if params[:path][2]
    end

    def build_topics_base_path
      base = build_forum_base_path
      if ! @topic.nil?
	base << [ '%s Forum', topics_list_url_for, @forum.name ]
      end
      base
    end
  end

  include TopicsModule

  def topics_path(path, url=nil)
    base = build_topics_base_path
    cms_page_path base, ['%s', url, path]
  end
end