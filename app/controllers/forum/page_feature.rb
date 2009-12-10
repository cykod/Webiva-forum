# Copyright (C) 2009 Pascal Rettig.

class Forum::PageFeature < ParagraphFeature

  include ActionView::Helpers::DateHelper

  feature :forum_page_categories, :default_feature => <<-FEATURE
    <cms:categories>
      <cms:category>
        <div class="forum_category">
          <h2><cms:category_link><cms:name/> Forums</cms:category_link></h2>
        </div>
        <cms:forums>
          <cms:forum>
            <div class="forum">
              <cms:image align='left' border='10' size='icon' ><cms:forum_link><cms:value/></cms:forum_link></cms:image>
              <h4><cms:forum_link><cms:name/></cms:forum_link></h4>
              <div style="clear:both;"></div>
            </div>
          </cms:forum>
        </cms:forums>
      </cms:category>
      <cms:pages/>
    </cms:categories>
  FEATURE

  def forum_page_categories_feature(data)
    webiva_feature(:forum_page_categories) do |c|
      c.loop_tag('category') { |t| data[:categories] }
        add_category_features(c, data)
          c.loop_tag('category:forum') { |t| t.locals.category.main_forums }
            add_forum_features(c, data, 'category:forum')
      c.pagelist_tag('pages', :field => 'forum_page' ) { |t| data[:pages] }
    end
  end

  feature :forum_page_list, :default_feature => <<-FEATURE
    <cms:category>
      <h1><cms:name/> Forums</h1>
      <cms:forums>
        <cms:forum>
          <div class="forum">
            <cms:image align='left' border='10' size='thumb' ><cms:forum_link><cms:value/></cms:forum_link></cms:image>
            <h3><cms:forum_link><cms:name/></cms:forum_link></h3>
            <div class="topics"><cms:topics_count/></div>
            <cms:description><div class="description"><cms:value/></div></cms:description>
            <div style="clear:both;"></div>
          </div>
        </cms:forum>
        <cms:pages/>
      </cms:forums>
    </cms:category>
  FEATURE
  
  def forum_page_list_feature(data)
    webiva_feature(:forum_page_list) do |c|
      c.define_tag('category') do |t|
	t.locals.category = data[:category]
	data[:category] ? t.expand : nil
      end

      add_category_features(c, data)

      c.loop_tag('forum') { |t| data[:forums] }
        add_forum_features(c, data)

      c.pagelist_tag('pages', :field => 'forum_page' ) { |t| data[:pages] }
    end
  end

  feature :forum_page_forum, :default_feature => <<-FEATURE
    <cms:category>
      <h1><cms:category_link><cms:name/> Forums</cms:category_link></h1>
      <cms:forum>
        <div class="forum">
          <cms:image align='left' border='10' size='small' ><cms:forum_link><cms:value/></cms:forum_link></cms:image>
          <h3><cms:forum_link><cms:name/></cms:forum_link></h3>
          <div style="clear:both;"></div>
        </div>
        <div class="new-topic">
          <cms:new_topic_link>Start a New Topic</cms:new_topic_link>
        </div>
        <cms:topics>
          <cms:topic>
            <cms:not_sticky>
            <div class="topic">
            </cms:not_sticky>
            <cms:sticky>
            <div class="sticky-topic">
            </cms:sticky>
              <div class="subject"><cms:topic_link><cms:subject/></cms:topic_link></div>
              <div class="count"><cms:posts_count/></div>
            </div>
          </cms:topic>
        </cms:topics>
      </cms:forum>
      <cms:pages/>
    </cms:category>
  FEATURE
  
  def forum_page_forum_feature(data)
    webiva_feature(:forum_page_forum) do |c|
      c.expansion_tag('category') { |t| t.locals.category = data[:forum].forum_category }

      add_category_features(c, data)

      c.expansion_tag('forum') { |t| t.locals.forum = data[:forum] }

      add_forum_features(c, data)

      c.loop_tag('forum:topic') { |t| data[:topics] }
        add_topic_features(c, data, 'forum:topic')

      c.pagelist_tag('pages', :field => 'forum_page' ) { |t| data[:pages] }
    end
  end

  feature :forum_page_topic, :default_feature => <<-FEATURE
    <cms:category>
      <cms:forum>
        <cms:topic>
          <cms:posts>
            <cms:post>
              <div class="post">
                <div class="by"><cms:posted_by/></div>
                <div class="date">Posted <cms:posted_ago/> ago</div>
                <div class="body">
                  <cms:subject><strong><cms:value/></strong></cms:subject>
                  <cms:body/>
                  <cms:attachment>
                    <cms:image size="small"/>
                    <cms:no_image>
                      <br/><a href="<cms:url/>"><img src="<cms:thumbnail_url/>" width="32"></a> Download <a href="<cms:url/>"><cms:name/></a>
                    </cms:no_image>
                  </cms:attachment>
                </div>
              </div>
            </cms:post>
          </cms:posts>
        </cms:topic>
      </cms:forum>
      <cms:pages/>
    </cms:category>
  FEATURE
  
  def forum_page_topic_feature(data)
    webiva_feature(:forum_page_topic) do |c|
      c.expansion_tag('category') { |t| t.locals.category = data[:forum].forum_category }
      add_category_features(c, data)

      c.expansion_tag('forum') { |t| t.locals.forum = data[:forum] }
      add_forum_features(c, data)

      c.expansion_tag('forum:topic') { |t| t.locals.topic = data[:topic] }
      add_topic_features(c, data, 'forum:topic')

      c.loop_tag('forum:topic:post') { |t| data[:posts] }
        add_post_features(c, data, 'forum:topic:post')

      c.pagelist_tag('pages', :field => 'posts_page' ) { |t| data[:pages] }
    end
  end

  feature :forum_page_new_post, :default_feature => <<-FEATURE
    <cms:no_topic>
      <h3>Start a New Topic</h3>
    </cms:no_topic>

    <cms:new_post>
      <cms:errors><div class='errors'><cms:value/></div></cms:errors>
      Subject:<br/><cms:subject/><br/>
      Body:<br/><cms:body/><br/>
      <cms:attachment>
        Attachment:<br/><cms:file/><br/>
      </cms:attachment>
      <cms:submit/>
    </cms:new_post>
  FEATURE
  
  def forum_page_new_post_feature(data)
    webiva_feature(:forum_page_new_post) do |c|
      c.expansion_tag('category') { |t| t.locals.category = data[:forum].forum_category }

      add_category_features(c, data)

      c.expansion_tag('forum') { |t| t.locals.forum = data[:forum] }

      add_forum_features(c, data)

      c.expansion_tag('topic') { |t| data[:topic] ? t.locals.topic = data[:topic] : nil }

      add_topic_features(c, data)

      c.form_for_tag('new_post','post', :html => {:multipart => true}) { |t| t.locals.post = data[:post] }
        c.form_error_tag('new_post:errors')
        c.field_tag('new_post:subject')
        c.field_tag('new_post:body', :control => 'text_area', :rows => 6, :cols => 50)
        c.expansion_tag('new_post:attachment') { |t| t.locals.post.can_add_attachments? }
          c.field_tag('new_post:attachment:file', :field => 'attachment_id', :control => 'upload_document')
        c.submit_tag('new_post:submit', :default => 'Submit')

    end
  end

  feature :forum_page_recent, :default_feature => <<-FEATURE
    <cms:topics>
      <h3>Active Topics</h3>
      <cms:topic>
        <div class="topic">
          <div class="subject"><cms:topic_link><cms:subject/></cms:topic_link></div>
          <div class="count"><cms:posts_count/></div>
        </div>
      </cms:topic>
      <cms:pages/>
    </cms:topics>
    <cms:no_topics>
      <p>No recent activity</p>
    </cms:no_topics>
  FEATURE
  
  def forum_page_recent_feature(data)
    webiva_feature(:forum_page_recent) do |c|
      c.expansion_tag('category') { |t| t.locals.category = data[:category] }

      add_category_features(c, data)

      c.expansion_tag('forum') { |t| t.locals.forum = data[:forum] }

      add_forum_features(c, data)

      c.loop_tag('topic') { |t| data[:topics] }
        add_topic_features(c, data)

      c.pagelist_tag('pages', :field => 'forum_page' ) { |t| data[:pages] }
    end
  end

  def add_category_features(context, data, base='category')
    context.h_tag(base + ':name') { |t| t.locals.category.name }
    context.link_tag(base + ':category') { |t| "#{data[:options].category_page_url}/#{t.locals.category.url}" }
  end

  def add_forum_features(context, data, base='forum')
    context.h_tag(base + ':name') { |t| t.locals.forum.name }
    context.h_tag(base + ':description') { |t| t.locals.forum.description }
    context.image_tag(base + ':image') { |t| t.locals.forum.image }
    context.link_tag(base + ':forum') { |t| "#{data[:options].forum_page_url}/#{t.locals.forum.url}" }
    context.date_tag(base + ':updated_at',DEFAULT_DATETIME_FORMAT.t) { |t| t.locals.forum.updated_at }
    context.value_tag(base + ':updated_ago') { |t| time_ago_in_words(t.locals.forum.updated_at) }
    context.date_tag(base + ':created_at',DEFAULT_DATETIME_FORMAT.t) { |t| t.locals.forum.created_at }
    context.value_tag(base + ':created_ago') { |t| time_ago_in_words(t.locals.forum.created_at) }
    context.h_tag(base + ':topics_count') { |t| pluralize(t.locals.forum.forum_topics_count, 'topic') }
    context.expansion_tag(base + ':on_main_page') { |t| t.locals.forum.main_page }

    if data[:options].new_post_page_id && ! data[:options].new_post_page_id.blank?
      context.link_tag(base + ':new_topic') { |t| "#{data[:options].new_post_page_url}/#{t.locals.forum.url}" }
    end
  end

  def add_topic_features(context, data, base='topic')
    context.h_tag(base + ':subject') { |t| t.locals.topic.subject }
    context.h_tag(base + ':posted_by') { |t| t.locals.topic.posted_by }
    context.link_tag(base + ':topic') { |t| "#{data[:options].forum_page_url}/#{t.locals.topic.forum_forum.url}/#{t.locals.topic.id}" }
    context.h_tag(base + ':posts_count') { |t| pluralize(t.locals.topic.forum_posts_count, 'post') }
    context.h_tag(base + ':activity_count') { |t| pluralize(t.locals.topic.activity_count, 'post') }
    context.date_tag(base + ':updated_at',DEFAULT_DATETIME_FORMAT.t) { |t| t.locals.topic.updated_at }
    context.value_tag(base + ':updated_ago') { |t| time_ago_in_words(t.locals.topic.updated_at) }
    context.date_tag(base + ':created_at',DEFAULT_DATETIME_FORMAT.t) { |t| t.locals.topic.created_at }
    context.value_tag(base + ':created_ago') { |t| time_ago_in_words(t.locals.topic.created_at) }
    context.expansion_tag(base + ':sticky') { |t| t.locals.topic.sticky > 0 }

    if data[:options].new_post_page_id && ! data[:options].new_post_page_id.blank?
      context.link_tag(base + ':new_post') { |t| "#{data[:options].new_post_page_url}/#{t.locals.forum.url}/#{t.locals.topic.id}" }
    end
  end

  def add_post_features(context, data, base='post')
    context.h_tag(base + ':subject') { |t| t.locals.post.subject }
    context.h_tag(base + ':posted_by') { |t| t.locals.post.posted_by }
    context.value_tag(base + ':body') { |t| t.locals.post.body_html }

    context.expansion_tag(base + ':attachment') { |t| t.locals.attachment = t.locals.post.attachment }
      add_attachment_features(context, data, base + ':attachment')

    context.date_tag(base + ':edited_at',DEFAULT_DATETIME_FORMAT.t) { |t| t.locals.post.edited_at }
    context.value_tag(base + ':edited_ago') { |t| time_ago_in_words(t.locals.post.edited_at) }
    context.date_tag(base + ':posted_at',DEFAULT_DATETIME_FORMAT.t) { |t| t.locals.post.posted_at }
    context.value_tag(base + ':posted_ago') { |t| time_ago_in_words(t.locals.post.posted_at) }
  end

  def add_attachment_features(context, data, base='attachment')
    context.h_tag(base + ':name') { |t| t.locals.attachment.name }
    context.image_tag(base + ':image') { |t| t.locals.attachment.image? ? t.locals.attachment : nil }
    context.value_tag(base + ':url') { |t| t.locals.attachment.full_url }
    context.value_tag(base + ':thumbnail_url') { |t| t.locals.attachment.thumbnail_url('standard', :icon) }
  end
end
