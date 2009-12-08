# Copyright (C) 2009 Pascal Rettig.

class Forum::PageController < ParagraphController

  editor_header 'Forum Paragraphs'

  editor_for :categories, :name => 'List of Forum Categories', :feature => :forum_page_categories
  editor_for :list, :name => "List of Forums", :feature => :forum_page_list, :inputs => [[:url, 'Category Url', :path]]
  editor_for :forum, :name => "Forum Display", :feature => :forum_page_forum,
             :inputs => { :forum => [[:url, 'Forum Url', :path]], 
                          :topic => [[:id, 'Topic Id', :path]] }
  editor_for :topic, :name => "Forum Topic Display", :feature => :forum_page_topic,
             :inputs => { :forum => [[:url, 'Forum Url', :path]], 
                          :topic => [[:id, 'Topic Id', :path]] }
  editor_for :recent, :name => "Recent Posts Display", :feature => :forum_page_recent

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
    attributes :forum_forum_id => nil, :topics_per_page => 20, :category_page_id => nil, :forum_page_id => nil

    integer_options :forum_forum_id, :topics_per_page

    page_options :category_page_id
    page_options :forum_page_id
  end

  class TopicOptions < HashModel
    attributes :posts_per_page => 20, :category_page_id => nil, :forum_page_id => nil

    integer_options :posts_per_page

    page_options :category_page_id
    page_options :forum_page_id
  end

  class RecentOptions < HashModel
  end

end
