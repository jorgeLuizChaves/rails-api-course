require 'rails_helper'

shared_examples_for "unauthorized_requests" do
  let(:error) do
    {
        "status" => "401",
        "source" => { "pointer" => "/code" },
        "title" =>  "Authentication code is invalid",
        "detail" => "You must provide valid code in order to exchange it for token."
    }
  end

  it 'should return 401 status code' do
    expect(subject).to have_http_status :unauthorized
  end

  it 'should return proper error body' do
    subject
    expect( json['errors'] ).to include(error)
  end
end

shared_examples_for 'forbidden_access' do
  let(:authorization_error) do
    {
        "status" => "403",
        "source"=> { "pointer" => "/headers/authorization" },
        "title"=> "Not authorized",
        "detail"=> "You have no right access to this resource."
    }
  end

  it 'should return 403 status code' do
    expect(subject).to have_http_status :forbidden
  end

  it 'should return proper error json' do
    subject
    expect(json_errors).to include(authorization_error)
  end
end