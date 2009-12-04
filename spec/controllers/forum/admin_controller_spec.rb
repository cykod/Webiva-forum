require  File.expand_path(File.dirname(__FILE__)) + "/../../../../../../spec/spec_helper"

require  File.expand_path(File.dirname(__FILE__)) + '/../../forum_test_helper'

describe Forum::AdminController do

  include ForumTestHelper

  it "should be able to create categories" do
    @myself = EndUser.push_target('test@webiva.com')
    @myself.user_class = UserClass.client_user_class
    @myself.client_user_id = 1
    @myself.save
      
    controller.should_receive('myself').at_least(:once).and_return(@myself)
  end

end


