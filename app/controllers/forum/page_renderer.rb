# Copyright (C) 2009 Pascal Rettig.


class Forum::PageRenderer < ParagraphRenderer

  include EndUserTable::Controller

  features '/forum/page_feature'

  paragraph :categories
  paragraph :list
  paragraph :forum
  paragraph :topic
  paragraph :new_post
  paragraph :recent

  def categories
    @options = paragraph_options(:categories)

    @pages, @categories = ForumCategory.paginate(params[:forum_page], :per_page => @options.categories_per_page, :order => 'name' )

    render_paragraph :feature => :forum_page_categories
  end

  def list
    @options = paragraph_options(:list)

    if editor?
      @category = ForumCategory.find(:first)
    elsif @options.forum_category_id.blank?
      conn_type, conn_id = page_connection
      @category = ForumCategory.find_by_url conn_id
    else
      @category = ForumCategory.find @options.forum_category_id
    end

    if @category
      @pages, @forums = @category.forum_forums.paginate(params[:forum_page], :per_page => @options.forums_per_page, :order => 'weight DESC, name' )
    end

    render_paragraph :feature => :forum_page_list
  end

  def forum
    @options = paragraph_options(:forum)

    if editor?
      if @options.forum_forum_id.blank?
	@forum = ForumForum.find(:first)
      else
	@forum = ForumForum.find_by_id @options.forum_forum_id
      end
    elsif @options.forum_forum_id.blank?
      conn_type, conn_id = page_connection(:forum)
      raise SiteNodeEngine::MissingPageException.new( site_node, language ) unless conn_type == :url

      @forum = ForumForum.find_by_url conn_id
      raise SiteNodeEngine::MissingPageException.new( site_node, language ) unless @forum

      conn_type, conn_id = page_connection(:topic)
      if conn_type == :id
	@topic = @forum.forum_topics.find_by_id conn_id
      end
    else
      @forum = ForumForum.find @options.forum_forum_id
    end

    if @forum && @topic.nil?
      @pages, @topics = @forum.forum_topics.paginate(params[:forum_page], :per_page => @options.topics_per_page, :order => 'sticky, created_at DESC')
    end

    render_paragraph :feature => :forum_page_forum
  end

  def topic
    @options = paragraph_options(:topic)

    if editor?
      if @options.forum_forum_id.blank?
	@forum = ForumForum.find(:first)
      else
	@forum = ForumForum.find_by_id @options.forum_forum_id
      end
      @topic = @forum.forum_topics.find(:first) if @forum;
    else
      if @options.forum_forum_id.blank?
	conn_type, conn_id = page_connection(:forum)
	if conn_type == :url
	  @forum = ForumForum.find_by_url conn_id
	end
      else
	@forum = ForumForum.find @options.forum_forum_id
      end

      conn_type, conn_id = page_connection(:topic)
      if conn_type == :id
	@topic = @forum.forum_topics.find_by_id conn_id if @forum
      end
    end

    if @topic
      @pages, @posts = @topic.forum_posts.approved_posts.paginate(params[:posts_page], :per_page => @options.posts_per_page, :order => 'posted_at')
      render_paragraph :feature => :forum_page_topic
    else
      render_paragraph :text => ''
    end
  end

  def new_post
    @options = paragraph_options(:forum)

    if editor?
      if @options.forum_forum_id.blank?
	@forum = ForumForum.find(:first)
      else
	@forum = ForumForum.find_by_id @options.forum_forum_id
      end
    else
      if @options.forum_forum_id.blank?
	conn_type, conn_id = page_connection(:forum)
	raise SiteNodeEngine::MissingPageException.new( site_node, language ) unless conn_type == :url

	@forum = ForumForum.find_by_url conn_id
	raise SiteNodeEngine::MissingPageException.new( site_node, language ) unless @forum
      else
	@forum = ForumForum.find @options.forum_forum_id
      end

      conn_type, conn_id = page_connection(:topic)
      if conn_type == :id && ! conn_id.blank?
	@topic = @forum.forum_topics.find conn_id.to_i
      end
    end

    @post = @topic ? @topic.build_post : @forum.forum_posts.build
    @post.end_user = myself

    if request.post? && params[:post]
      if @post.update_attributes(params[:post].slice(:subject, :body))
	redirect_to @options.forum_page_url + '/' + @forum.url + '/' + @post.forum_topic.id.to_s
      end
    end

    render_paragraph :feature => :forum_page_new_post
  end

  def recent
  
    render_paragraph :feature => :forum_page_recent
  end

end
