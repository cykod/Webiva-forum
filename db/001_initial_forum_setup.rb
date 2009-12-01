class InitialForumSetup < ActiveRecord::Migration
  def self.up

    create_table :forums, :force => true do |t|
      t.integer :parent_id
      t.string :name
      t.text :description
      t.string :markup_language
    end
    
    create_table :forum_topics, :force => true do |t|
      t.integer :forum_id
      t.integer :end_user_id
      t.string :posted_by
      t.string :subject
      t.text :body, :limit => 2.megabytes
      t.text :body_html, :limit => 2.megabytes
      
      t.column :posted_at, :datetime
      t.column :edited_at, :datetime
    end
    
    add_index :forum_topics, [ :forum_id ], :name => 'forum_id'
    
    create_table :forum_posts, :force => true do |t|
      t.integer :forum_topic_id
      t.integer :end_user_id
      t.string :posted_by
      t.string :subject
      t.text :body, :limit => 2.megabytes
      t.text :body_html, :limit => 2.megabytes
      
      t.column :posted_at, :datetime
      t.column :edited_at, :datetime
    end
    
    add_index :forum_posts, [ :forum_topic_id, :posted_at ], :name => 'topic_posted'
    add_index :forum_posts, [ :posted_at ], :name => 'posted_at'

    create_table :forum_subscriptions, :force => true do |t|
      t.integer :end_user_id
      t.integer :topic_id
      t.integer :forum_id
    end
    
    add_index :forum_subscriptions, :topic_id, :name => 'topic_id'
    add_index :forum_subscriptions, [ :forum_id, :topic_id ], :name => 'forum_topic_id'
  end
   
  def self.down
    drop_table :forums
    drop_table :forum_topics
    drop_table :forum_posts
    drop_table :forum_subscriptions
  end

end
