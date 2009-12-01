# Copyright (C) 2009 Pascal Rettig.



class Forum::PageFeature < ParagraphFeature


  feature :forum_page_list, :default_feature => <<-FEATURE
    List Feature Code...
  FEATURE
  

  def forum_page_list_feature(data)
    webiva_feature(:forum_page_list) do |c|
      # c.define_tag ...
    end
  end
  feature :forum_page_forum, :default_feature => <<-FEATURE
    Forum Feature Code...
  FEATURE
  

  def forum_page_forum_feature(data)
    webiva_feature(:forum_page_forum) do |c|
      # c.define_tag ...
    end
  end
  feature :forum_page_topic, :default_feature => <<-FEATURE
    Topic Feature Code...
  FEATURE
  

  def forum_page_topic_feature(data)
    webiva_feature(:forum_page_topic) do |c|
      # c.define_tag ...
    end
  end
  feature :forum_page_recent, :default_feature => <<-FEATURE
    Recent Feature Code...
  FEATURE
  

  def forum_page_recent_feature(data)
    webiva_feature(:forum_page_recent) do |c|
      # c.define_tag ...
    end
  end


end
