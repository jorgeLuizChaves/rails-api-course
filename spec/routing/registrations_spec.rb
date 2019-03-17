require 'rails_helper'

describe 'Registrations routes' do
  it 'should route to registration create' do
    expect(post 'sign_up').to route_to('registrations#create')
  end
end