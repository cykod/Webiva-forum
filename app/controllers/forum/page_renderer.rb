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
      raise SiteNodeEngine::MissingPageException.new( site_node, language ) unless @category
    else
      @category = ForumCategory.find @options.forum_category_id
      raise SiteNodeEngine::MissingPageException.new( site_node, language ) unless @category
    end

    if @category
      set_page_connection :category, @category
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
    elsif ! @options.forum_forum_id.blank?
      @forum = ForumForum.find @options.forum_forum_id
      raise SiteNodeEngine::MissingPageException.new( site_node, language ) unless @forum
    else
      conn_type, conn_id = page_connection(:forum)
      raise SiteNodeEngine::MissingPageException.new( site_node, language ) unless conn_type == :url

      @forum = ForumForum.find_by_url conn_id
      raise SiteNodeEngine::MissingPageException.new( site_node, language ) unless @forum

      conn_type, conn_id = page_connection(:topic)
      if conn_type == :id
	@topic = @forum.forum_topics.find_by_id conn_id
      end
    end

    if @forum && @topic.nil?
      @pages, @topics = @forum.forum_topics.paginate(params[:forum_page], :per_page => @options.topics_per_page, :order => 'sticky, created_at DESC')
    end

    set_page_connection :forum, @forum
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
      set_page_connection :topic, @topic
      @pages, @posts = @topic.forum_posts.approved_posts.paginate(params[:posts_page], :per_page => @options.posts_per_page, :order => 'posted_at')
      render_paragraph :feature => :forum_page_topic
    else
      render_paragraph :text => ''
    end
  end

  def new_post
    @options = paragraph_options(:new_post)

    if editor?
      if @options.forum_forum_id.blank?
	@forum = ForumForum.find(:first)
      else
	@forum = ForumForum.find_by_id @options.forum_forum_id
      end
    else
      if @options.forum_forum_id.blank?
	conn_type, conn_id = page_connection
	if conn_type == :forum
	  @forum = conn_id
	elsif conn_type == :topic
	  @topic = conn_id
	  @forum = @topic.forum_forum
	elsif conn_type == :forum_path
	  @forum = ForumForum.find_by_url conn_id
	  raise SiteNodeEngine::MissingPageException.new( site_node, language ) unless @forum

	  conn_type, conn_id = page_connection(:topic)
	  if conn_type == :id && ! conn_id.blank?
	    @topic = @forum.forum_topics.find conn_id
	  end
	else
	  return render_paragraph :text => '[Configure page connections]'
	end
      else
	@forum = ForumForum.find @options.forum_forum_id
      end
    end

    if @topic
      if ! @forum.allowed_to_create_post?(myself)
	return render_paragraph :text => ''
      end
    elsif ! @forum.allowed_to_create_topic?(myself)
      return render_paragraph :text => ''
    end

    @post = @topic ? @topic.build_post : @forum.forum_posts.build
    @post.end_user = myself

    if request.post? && params[:post]
      if @post.update_attributes(params[:post].slice(:subject, :body))
	posts_page = ((@post.forum_topic.forum_posts.size-1) / @options.posts_per_page).to_i + 1
	if posts_page > 1
	  redirect_paragraph @options.forum_page_url + '/' + @forum.url + '/' + @post.forum_topic.id.to_s + '?posts_page=' + posts_page.to_s
	else
	  redirect_paragraph @options.forum_page_url + '/' + @forum.url + '/' + @post.forum_topic.id.to_s
	end
      end
    else
      render_paragraph :feature => :forum_page_new_post
    end
  end

  def recent
    @options = paragraph_options(:recent)

    if editor?
      if ! @options.forum_category_id.blank?
	@category = ForumCategory.find_by_id @options.forum_category_id
      elsif ! @options.forum_forum_id.blank?
	@forum = ForumForum.find_by_id @options.forum_forum_id
	@category = @forum.forum_category
      else
	@category = ForumCategory.find(:first)
      end
    elsif ! @options.forum_category_id.blank?
      @category = ForumCategory.find @options.forum_category_id
    elsif ! @options.forum_forum_id.blank?
      @forum = ForumForum.find @options.forum_forum_id
      @category = @forum.forum_category
    else
      conn_type, conn_id = page_connection

      if conn_type == :category
	@category = conn_id
      elsif conn_type == :forum
	@forum = conn_id
	@category = @forum.forum_category
      elsif conn_type == :category_path
	@category = ForumCategory.find_by_url conn_id
	raise SiteNodeEngine::MissingPageException.new( site_node, language ) unless @category

	conn_type, conn_id = page_connection(:forum)
	if ! conn_id.blank? && conn_type == :url
	  @forum = @category.forum_forums.find_by_url conn_id
	  raise SiteNodeEngine::MissingPageException.new( site_node, language ) unless @forum
	end
      else
	return render_paragraph :text => '[Configure page connections]'
      end
    end

    if @forum
      @pages, @topics = @forum.forum_topics.recent_topics.paginate(params[:forum_page], :per_page => @options.topics_per_page, :order => 'activity_count')
    elsif @category
      @pages, @topics = @category.forum_topics.recent_topics.paginate(params[:forum_page], :per_page => @options.topics_per_page, :order => 'activity_count')
    end

    render_paragraph :feature => :forum_page_recent
  end

end
