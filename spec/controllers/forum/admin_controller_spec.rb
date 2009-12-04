require  File.expand_path(File.dirname(__FILE__)) + "/../../../../../../spec/spec_helper"

require  File.expand_path(File.dirname(__FILE__)) + '/../../forum_test_helper'

describe Forum::AdminController do

  include ForumTestHelper

  it "should be able to create categories" do
    mock_editor

    get 'options'
  end

end


