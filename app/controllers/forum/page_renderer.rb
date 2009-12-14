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

    result = renderer_cache(ForumCategory) do |cache|
      @categories = ForumCategory.find(:all, :order => 'name' )
      cache[:output] = forum_page_categories_feature
    end

    render_paragraph :text => result.output
  end

  def list
    @options = paragraph_options(:list)

    if editor?
      @category = ForumCategory.find(:first)
    elsif @options.forum_category_id.blank?
      conn_type, conn_id = page_connection
      @category = ForumCategory.find_by_url conn_id if conn_type == :url && ! conn_id.blank?
      raise SiteNodeEngine::MissingPageException.new( site_node, language ) unless @category
    else
      @category = ForumCategory.find @options.forum_category_id
      raise SiteNodeEngine::MissingPageException.new( site_node, language ) unless @category
    end

    forum_page = (params[:forum_page] || 1).to_i

    result = renderer_cache(@category, forum_page) do |cache|
      @pages, @forums = @category.forum_forums.paginate(forum_page, :per_page => @options.forums_per_page, :order => 'weight DESC, name' )
      cache[:output] = forum_page_list_feature
    end

    if ! result.output
      return render_paragraph :text => ''
    end

    set_page_connection :category, @category
    set_title @category.name, 'category'
    render_paragraph :text => result.output
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
      @forum = ForumForum.find_by_url conn_id if conn_type == :url && ! conn_id.blank?
      raise SiteNodeEngine::MissingPageException.new( site_node, language ) unless @forum
    end

    forum_page = (params[:forum_page] || 1).to_i
    conn_type, conn_id = page_connection(:topic)
    must_fetch_topic = (conn_type == :id && ! conn_id.blank?)

    cache_obj = must_fetch_topic ? [ForumTopic, conn_id.to_i] : @forum

    result = renderer_cache(cache_obj, forum_page) do |cache|
      @topic = @forum.forum_topics.find_by_id conn_id.to_i if must_fetch_topic

      if @forum && ! must_fetch_topic
	@pages, @topics = @forum.forum_topics.paginate(forum_page, :per_page => @options.topics_per_page, :order => 'sticky DESC, created_at DESC')
      end

      cache[:output] = forum_page_forum_feature
    end

    set_page_connection :forum, @forum
    set_title @forum.name, 'forum'
    render_paragraph :text => result.output
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
	@forum = ForumForum.find_by_url conn_id if conn_type == :url && ! conn_id.blank?
      else
	@forum = ForumForum.find @options.forum_forum_id
      end

      conn_type, conn_id = page_connection(:topic)
      @topic = @forum.forum_topics.find_by_id conn_id if conn_type == :id && ! conn_id.blank? && @forum
    end

    if @topic
      posts_page = (params[:posts_page] || 1).to_i
      display_string = "#{posts_page}"

      skip = false
      default_subscription_template_id = Forum::AdminController.module_options.subscription_template_id
      if @topic.subscribe?(myself, default_subscription_template_id)
	display_string << "_#{myself.id}"
	@subscription = ForumSubscription.find_by_end_user_id_and_forum_topic_id(myself.id, @topic.id)
	@subscription = @topic.build_subscription(myself) if @subscription.nil?
	display_string << "_#{@subscription.id ? 'u' : 's'}"
	if request.post?
	  skip = true
	  if params[:subscribe] && params[:subscribe].blank?
	    @subscription.destroy if @subscription.subscribed?
	    @subscription = @topic.build_subscription(myself)
	    flash[:notice] = 'Unsubscribed from topic';
	  else
	    @subscription.save unless @subscription.subscribed?
	    flash[:notice] = 'Subscribed to topic';
	  end
	end
      end

      result = renderer_cache(@topic, display_string, :skip => skip) do |cache|
	@pages, @posts = @topic.forum_posts.approved_posts.paginate(posts_page, :per_page => @options.posts_per_page, :order => 'posted_at')
	cache[:output] = forum_page_topic_feature
      end

      set_page_connection :topic, @topic
      set_title @forum.name, 'forum'
      set_title @topic.subject[0..68], 'subject'
      render_paragraph :text => result.output
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
	  @topic = @forum.forum_topics.find conn_id if conn_type == :id && ! conn_id.blank?
	else
	  return render_paragraph :text => '[Configure page connections]'
	end
      else
	@forum = ForumForum.find @options.forum_forum_id

	conn_type, conn_id = page_connection
	if conn_type == :content
	  @content = conn_id
	end
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

    if @content
      @post.content_type = @content[0]
      @post.content_id = @content[1]
    end

    if request.post? && params[:post]
      if @post.can_add_attachments?
	handle_file_upload params[:post], 'attachment_id', {:folder => @post.upload_folder_id}
      end

      if @post.update_attributes(params[:post].slice(:subject, :body, :attachment_id))
	posts_page = ((@post.forum_topic.forum_posts.size-1) / @options.posts_per_page).to_i + 1
	if posts_page > 1
	  posts_url = @options.forum_page_url + '/' + @forum.url + '/' + @post.forum_topic.id.to_s + '?posts_page=' + posts_page.to_s
	else
	  posts_url = @options.forum_page_url + '/' + @forum.url + '/' + @post.forum_topic.id.to_s
	end

	default_subscription_template_id = Forum::AdminController.module_options.subscription_template_id
	@post.send_subscriptions!( {:url => posts_url, :subject => @post.subject, :message => @post.body}, default_subscription_template_id )
	return redirect_paragraph posts_url
      end
    end

    set_title @topic.subject[0..68], 'subject' if @topic
    set_title @forum.name, 'forum'
    set_title @topic ? @topic.subject[0..68] : @forum.name

    render_paragraph :feature => :forum_page_new_post
  end

  def recent
    return render_paragraph :text => '[Configure Page Connections]' unless recent_options

    forum_page = (params[:forum_page] || 1).to_i
    display_string = "#{forum_page}"
    if @content
      display_string << "_#{@content[0]}_#{@content[1]}"
    end

    cache_obj = @forum_url ? [ForumForum, @forum_url] : [ForumCategory, @category_path]
    result = renderer_cache(cache_obj, display_string) do |cache|
      if @forum_url
	@forum = ForumForum.find_by_url @forum_url unless @forum
	raise MissingPageException.new( site_node, language ) unless @forum

	@category = @forum.forum_category unless @category
	raise MissingPageException.new( site_node, language ) unless @category.url == @category_path

	if @content
	  @pages, @topics = @forum.forum_topics.topics_for_content(*@content).order_by_recent_topics(1.day.ago).paginate(forum_page, :per_page => @options.topics_per_page)
	else
	  @pages, @topics = @forum.forum_topics.order_by_recent_topics(1.day.ago).paginate(forum_page, :per_page => @options.topics_per_page)
	end
      elsif @category_path
	@category = ForumCategory.find_by_url @category_path unless @category
	raise MissingPageException.new( site_node, language ) unless @category

	@pages, @topics = @category.forum_topics.order_by_recent_topics(1.day.ago).paginate(forum_page, :per_page => @options.topics_per_page)
      end

      cache[:category_title] = @category.name
      cache[:forum_title] = @forum ? @forum.name : ''
      cache[:default_title] = @forum ? @forum.name : @category.name
      cache[:output] = forum_page_recent_feature
    end

    set_title result.category_title, 'category'
    set_title result.forum_title, 'forum' if ! result.forum_title.blank?
    set_title result.default_title
    render_paragraph :text => result.output
  end

  protected

  def recent_options
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
      conn_type, conn_id = page_connection(:forum)
      @forum_url = conn_id if ! conn_id.blank? && conn_type == :url
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
	@category_path = conn_id if ! conn_id.blank?

	conn_type, conn_id = page_connection(:forum)
	@forum_url = conn_id if ! conn_id.blank? && conn_type == :url
      else
	return false
      end
    end

    conn_type, conn_id = page_connection(:content)
    @content = conn_id if conn_type == :content && ! conn_id.blank?

    @category_path = @category.url if @category
    @forum_url = @forum.url if @forum

    true
  end
end
