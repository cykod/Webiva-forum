# Copyright (C) 2009 Pascal Rettig.

class Forum::PageController < ParagraphController

  editor_header 'Forum Paragraphs'

  editor_for :categories, :name => 'List of Forum Categories', :feature => :forum_page_categories
  editor_for :list, :name => "List of Forums", :feature => :forum_page_list,
                    :inputs => [[:url, 'Category Url', :path]],
                    :outputs => [[:category, 'Forum Category Target', :forum_category_target]]

  editor_for :forum, :name => "Forum Display", :feature => :forum_page_forum,
                     :inputs => { :forum => [[:url, 'Forum Url', :path]], 
                                  :topic => [[:id, 'Topic Id', :path]] },
                     :outputs => [[:forum, 'Forum Target', :forum_forum_target]]

  editor_for :topic, :name => "Forum Topic Display", :feature => :forum_page_topic,
                     :inputs => { :forum => [[:url, 'Forum Url', :path]], 
                                  :topic => [[:id, 'Topic Id', :path]] },
                     :outputs => [[:topic, 'Topic Target', :forum_topic_target]]

  editor_for :new_post, :name => "New Post Form", :feature => :forum_page_new_post,
                        :inputs => { :input => [[:forum, 'Forum', :forum_forum_target],
                                                [:topic, 'Topic', :forum_topic_target],
                                                [:forum_path, 'Forum Url', :path]],
                                     :topic => [[:id, 'Topic Id (only used with Forum Url)', :path]]
                                   }

  editor_for :recent, :name => "Recent Posts Display", :feature => :forum_page_recent,
                      :inputs => { :input => [[:category, 'Category', :forum_category_target],
                                              [:forum, 'Forum', :forum_forum_target],
                                              [:category_path, 'Forum Category Url', :path]],
                                   :forum => [[:url, 'Forum Url (only used with Forum Category Url)', :path]]
                                 }

  class CategoriesOptions < HashModel
    attributes :categories_per_page => 20, :category_page_id => nil, :forum_page_id => nil

    integer_options :categories_per_page

    page_options :category_page_id
    page_options :forum_page_id
  end

  class ListOptions < HashModel
    attributes :forum_category_id => nil, :forums_per_page => 10, :forum_page_id => nil

    integer_options :forum_category_id, :forums_per_page

    page_options :forum_page_id
  end

  class ForumOptions < HashModel
    attributes :forum_forum_id => nil, :topics_per_page => 20, :category_page_id => nil, :forum_page_id => nil, :new_post_page_id => nil

    integer_options :forum_forum_id, :topics_per_page

    page_options :category_page_id
    page_options :forum_page_id
    page_options :new_post_page_id
  end

  class TopicOptions < HashModel
    attributes :forum_forum_id => nil, :posts_per_page => 20, :category_page_id => nil, :forum_page_id => nil, :new_post_page_id => nil

    integer_options :forum_forum_id, :posts_per_page

    page_options :category_page_id
    page_options :forum_page_id
    page_options :new_post_page_id
  end

  class NewPostOptions < HashModel
    attributes :forum_forum_id => nil, :posts_per_page => 20, :category_page_id => nil, :forum_page_id => nil

    integer_options :forum_forum_id, :posts_per_page

    page_options :category_page_id
    page_options :forum_page_id
  end

  class RecentOptions < HashModel
    attributes :forum_category_id => nil, :forum_forum_id => nil, :topics_per_page => 20, :category_page_id => nil, :forum_page_id => nil

    integer_options :forum_category_id, :forum_forum_id, :topics_per_page

    page_options :category_page_id
    page_options :forum_page_id
  end

end
