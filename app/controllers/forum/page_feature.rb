# Copyright (C) 2009 Pascal Rettig.

class Forum::PageFeature < ParagraphFeature

  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::NumberHelper

  feature :forum_page_categories, :default_feature => <<-FEATURE
    <cms:categories>
      <cms:category>
        <h1><cms:name/> Forums</h1>
        <cms:forums>
          <cms:forum>
            <h2><cms:forum_link><cms:name/></cms:forum_link></h2>
            <cms:description><p><cms:value/></p></cms:description>
          </cms:forum>
        </cms:forums>
        <cms:not_last><hr/></cms:not_last>
      </cms:category>
    </cms:categories>
  FEATURE

  def forum_page_categories_feature(data)
    webiva_feature(:forum_page_categories) do |c|
      c.loop_tag('category') { |t| data[:categories] }
        add_category_features(c, data)
          c.loop_tag('category:forum') { |t| t.locals.category.main_forums }
            add_forum_features(c, data, 'category:forum')
    end
  end

  feature :forum_page_list, :default_feature => <<-FEATURE
    <cms:category>
      <cms:forums>
        <cms:forum>
          <h2><cms:forum_link><cms:name/></cms:forum_link></h2>
          <cms:description><p><cms:value/></p></cms:description>
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
      <cms:forum>
        <h1><cms:forum_link><cms:name/></cms:forum_link></h1>
        <cms:description><p><cms:value/></p></cms:description>
        <span class="button"><cms:new_topic_link>New Thread</cms:new_topic_link></span>
        <hr/>
        <cms:topics>
          <cms:pages/>
          <table class="topics">
            <tr>
              <th align="left" width="60%">Threads</th>
              <th align="center" width="20%">Replies</th>
              <th align="left" width="20%">Created</th>
            </tr>
          <cms:topic>
            <tr>
              <td class="subject" valign="middle">
                <cms:topic_link><cms:subject/></cms:topic_link>
              </td>
              <td class="replies" align="center" valign="middle">
                <cms:replies/>
              </td>
              <td class="created" valign="middle">
                <cms:created_ago/> ago<br/>
                by <span><cms:posted_by/></span>
              </td>
            </tr>
          </cms:topic>
          </table>
          <cms:pages/>
        </cms:topics>
      </cms:forum>
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
        <h2><cms:forum_link><cms:name/></cms:forum_link></h2>
        <hr/>
        <cms:topic>
          <h1><cms:subject/></h1>
          <cms:subscription>
            <cms:form/>
          </cms:subscription>
          <br/>
          <cms:posts>
            <div class="pages"><cms:pages/></div>
            <table class="posts">
              <cms:post>
              <tr>
                <td width="15%" align="center" valign="baseline">
                  <cms:user><cms:img/></cms:user>
                </td>
                <td width="85%" class="post" valign="baseline">
                  <span class="by"><cms:posted_by/></span> <span class="date"><cms:posted_at format="%e.%b.%Y %l:%M%P"/></span>
                  <div class="body"><cms:body/></div>
                  <cms:attachment><div class="attachment">Attachment: <cms:attachment_link><cms:name/></cms:attachment_link></div></cms:attachment>
                  <cms:first>
                    <span class="button"><cms:new_post_link>New Reply</cms:new_post_link></span><br/>
                  </cms:first>
                </td>
              </tr>
              </cms:post>
            </table>
            <div class="pages"><cms:pages/></div>
          </cms:posts>
        </cms:topic>
      </cms:forum>
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

      c.expansion_tag('forum:topic:subscription') { |t| t.locals.subscription = data[:subscription] }
      c.define_tag('forum:topic:subscription:form') do |t|
        if t.single?
          label = t.attr['label'] || "Subscribe to topic"
        else
          label = t.expand
        end

        confirm_message =  t.locals.subscription.subscribed? ? (t.attr['unsubscribe_message'] || 'Are you sure you want to unsubscribe from topic?') : (t.attr['subscribe_message'] || 'Subscribe to topic?' )

        form_tag("") +
          tag(:label,:for => 'subscribe') +
          tag(:input,:type => 'hidden', :name => 'subscribe',:value => '') + 
          tag(:input,:type => 'checkbox',
              :id => 'subscribe',
              :checked => t.locals.subscription.subscribed?,
              :name => 'subscribe',
              :onclick => "if(confirm('#{jvh confirm_message}')) { this.form.submit(); return true; } else { return false; }") + " " + h(label) + "</form>"
      end

      c.loop_tag('forum:topic:post') { |t| data[:posts] }
        add_post_features(c, data, 'forum:topic:post')

      c.pagelist_tag('pages', :field => 'posts_page' ) { |t| data[:pages] }
    end
  end

  feature :forum_page_new_post, :default_feature => <<-FEATURE
    <cms:topic>
      <cms:forum>
        <h2>
          <cms:forum_link><cms:name/></cms:forum_link>
        </h2>
        <hr/>
      </cms:forum>
      <h1><cms:topic_link><cms:subject/></cms:topic_link></h1>
      <hr/>
      <cms:post_form>
        <cms:new_post>
          <cms:errors><div class='errors'><cms:value/></div></cms:errors>
          Body:<br/><cms:body/><br/>
          <cms:attachment>
            Attachment:<br/><cms:file/><br/>
          </cms:attachment>
          <cms:submit/>
        </cms:new_post>
      </cms:post_form>
      <cms:no_post_form>
        <div class='errors'>Must be logged in to reply.</div>
      </cms:no_post_form>
    </cms:topic>
    <cms:no_topic>
      <cms:forum>
        <h1><cms:forum_link><cms:name/></cms:forum_link></h1>
        <cms:description><p><cms:value/></p></cms:description>
        <hr/>
      </cms:forum>
      <cms:post_form>
        <cms:new_post>
          <cms:errors><div class='errors'><cms:value/></div></cms:errors>
          Subject:<br/><cms:subject/><br/>
          Body:<br/><cms:body/><br/>
          <cms:attachment>
            Attachment:<br/><cms:file/><br/>
          </cms:attachment>
          <cms:submit/>
        </cms:new_post>
      </cms:post_form>
      <cms:no_post_form>
        <div class='errors'>Must be logged in to create a new topic.</div>
      </cms:no_post_form>
    </cms:no_topic>
  FEATURE
  
  def forum_page_new_post_feature(data)
    webiva_feature(:forum_page_new_post) do |c|
      c.expansion_tag('category') { |t| t.locals.category = data[:forum].forum_category }
        add_category_features(c, data)

      c.expansion_tag('forum') { |t| t.locals.forum = data[:forum] }
        add_forum_features(c, data)

      c.expansion_tag('topic') { |t| data[:topic] ? t.locals.topic = data[:topic] : nil }
        add_topic_features(c, data)

      c.expansion_tag('post_form') { |t| data[:post] ? t.locals.post = data[:post] : nil }

      c.form_for_tag('post_form:new_post','post', :html => {:multipart => true}) { |t| t.locals.post = data[:post] }
        c.form_error_tag('post_form:new_post:errors')
        c.field_tag('post_form:new_post:subject')
        c.field_tag('post_form:new_post:body', :control => 'text_area', :rows => 6, :cols => 50)
        c.expansion_tag('post_form:new_post:attachment') { |t| t.locals.post.can_add_attachments? }
          c.field_tag('post_form:new_post:attachment:file', :field => 'attachment_id', :control => 'upload_document')
        c.submit_tag('post_form:new_post:submit', :default => 'Submit')

    end
  end

  feature :forum_page_recent, :default_feature => <<-FEATURE
    <h2>NEW ON THE FORUM</h2>
    <cms:topics>
      <cms:topic>
        <p><cms:topic_link><cms:subject/></cms:topic_link></p>
      </cms:topic>
    </cms:topics>
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
    context.value_tag(base + ':topics_count') { |t| number_with_delimiter(t.locals.forum.forum_topics_count) }
    context.value_tag(base + ':topics_count_topics') { |t| pluralize(t.locals.forum.forum_topics_count, 'topic') }
    context.expansion_tag(base + ':on_main_page') { |t| t.locals.forum.main_page }

    if data[:options] && data[:options].new_post_page_id && ! data[:options].new_post_page_id.blank?
      context.link_tag(base + ':new_topic') { |t| "#{data[:options].new_post_page_url}/#{t.locals.forum.url}" }
    end
  end

  def add_topic_features(context, data, base='topic')
    context.h_tag(base + ':subject') { |t| truncate(t.locals.topic.subject, :length => (t.attr['length'] || 100).to_i) }
    context.h_tag(base + ':posted_by') { |t| t.locals.topic.posted_by }
    context.link_tag(base + ':topic') { |t| "#{data[:options].forum_page_url}/#{t.locals.topic.forum_forum.url}/#{t.locals.topic.id}" }
    context.value_tag(base + ':posts_count') { |t| number_with_delimiter(t.locals.topic.forum_posts_count) }
    context.value_tag(base + ':replies') { |t| number_with_delimiter(t.locals.topic.forum_posts_count-1) }
    context.value_tag(base + ':activity_count') { |t| number_with_delimiter(t.locals.topic.activity_count) }
    context.value_tag(base + ':posts_count_posts') { |t| pluralize(t.locals.topic.forum_posts_count, 'post') }
    context.value_tag(base + ':activity_count_posts') { |t| pluralize(t.locals.topic.activity_count, 'post') }
    context.value_tag(base + ':views') { |t| number_with_delimiter(t.locals.topic.views) }
    context.value_tag(base + ':views_views') { |t| pluralize(t.locals.topic.views, 'view') }
    context.date_tag(base + ':updated_at',DEFAULT_DATETIME_FORMAT.t) { |t| t.locals.topic.updated_at }
    context.value_tag(base + ':updated_ago') { |t| time_ago_in_words(t.locals.topic.updated_at) }
    context.date_tag(base + ':created_at',DEFAULT_DATETIME_FORMAT.t) { |t| t.locals.topic.created_at }
    context.value_tag(base + ':created_ago') { |t| time_ago_in_words(t.locals.topic.created_at) }
    context.expansion_tag(base + ':sticky') { |t| t.locals.topic.sticky > 0 }

    if data[:options] && data[:options].new_post_page_id && ! data[:options].new_post_page_id.blank?
      context.link_tag(base + ':new_post') { |t| "#{data[:options].new_post_page_url}/#{t.locals.forum.url}/#{t.locals.topic.id}" }
    end

    context.expansion_tag(base + ':user') { |t| t.locals.user = t.locals.topic.end_user }
      context.define_user_details_tags(base + ':user')

    context.expansion_tag(base + ':first_post') { |t| t.locals.post = t.locals.topic.first_post }
      add_post_features(context, data, base + ':first_post')

    context.expansion_tag(base + ':last_post') { |t| t.locals.post = t.locals.topic.last_post }
      add_post_features(context, data, base + ':last_post')
  end

  def add_post_features(context, data, base='post')
    context.h_tag(base + ':subject') { |t| t.locals.post.subject }
    context.h_tag(base + ':posted_by') { |t| t.locals.post.posted_by }
    context.value_tag(base + ':body') { |t| t.locals.post.body_html }
    context.expansion_tag(base + ':first_post') { |t| t.locals.post.first_post }

    context.expansion_tag(base + ':attachment') { |t| t.locals.attachment = t.locals.post.attachment }
      add_attachment_features(context, data, base + ':attachment')

    context.date_tag(base + ':edited_at',DEFAULT_DATETIME_FORMAT.t) { |t| t.locals.post.edited_at }
    context.value_tag(base + ':edited_ago') { |t| time_ago_in_words(t.locals.post.edited_at) }
    context.date_tag(base + ':posted_at',DEFAULT_DATETIME_FORMAT.t) { |t| t.locals.post.posted_at }
    context.value_tag(base + ':posted_ago') { |t| time_ago_in_words(t.locals.post.posted_at) }

    context.expansion_tag(base + ':user') { |t| t.locals.user = t.locals.post.end_user }
      context.define_user_details_tags(base + ':user')
  end

  def add_attachment_features(context, data, base='attachment')
    context.h_tag(base + ':name') { |t| t.locals.attachment.name }
    context.image_tag(base + ':image') { |t| t.locals.attachment.image? ? t.locals.attachment : nil }
    context.link_tag(base + ':attachment') { |t| t.locals.attachment.full_url }
    context.value_tag(base + ':url') { |t| t.locals.attachment.full_url }
    context.value_tag(base + ':thumbnail_url') { |t| t.locals.attachment.thumbnail_url('standard', :icon) }
  end
end
