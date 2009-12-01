# Copyright (C) 2009 Pascal Rettig.



class Forum::PageRenderer < ParagraphRenderer

  features '/forum/page_feature'

  paragraph :list
  paragraph :forum
  paragraph :topic
  paragraph :recent

  def list
  
    render_paragraph :feature => :forum_page_list
  end
  def forum
  
    render_paragraph :feature => :forum_page_forum
  end
  def topic
  
    render_paragraph :feature => :forum_page_topic
  end

  def recent
  
    render_paragraph :feature => :forum_page_recent
  end


end
