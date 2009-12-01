# Copyright (C) 2009 Pascal Rettig.



class Forum::PageController < ParagraphController

  editor_header 'Forum Paragraphs'
  
  editor_for :list, :name => "List of Forums", :feature => :forum_page_list
  editor_for :forum, :name => "Forum Display", :feature => :forum_page_forum
  editor_for :topic, :name => "Forum Topic Display", :feature => :forum_page_topic
  editor_for :recent, :name => "Recent Posts Display", :feature => :forum_page_recent

  class ListOptions < HashModel

  end
  class ForumOptions < HashModel

  end
  class TopicOptions < HashModel

  end
  class RecentOptions < HashModel

  end

end
