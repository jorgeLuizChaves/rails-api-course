require 'rails_helper'

describe 'Access tokens routes' do
  it 'should route to access_tokens create action' do
    expect(post "/login").to route_to("access_tokens#create")
  end

  it 'should route to access_token delete action' do
    expect(delete '/logout').to route_to("access_tokens#destroy")
  end
end