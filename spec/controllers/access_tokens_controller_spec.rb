require 'rails_helper'

RSpec.describe AccessTokensController, type: :controller do

  describe '#create' do
    let(:params) do
      {
          data: {
              attributes: {
                  login: 'jsmith',
                  password: 'password'
              }
          }
      }
    end

    context 'when no code provided' do
      subject {post :create}
      it_behaves_like "unauthorized_requests"
    end

    context 'when invalid login provided' do
      let(:user) { create :user, login: 'invalid', password: 'password'}
      subject { post :create, params: params}
      before { user }
      it_behaves_like 'unauthorized_standard_requests'
    end

    context 'when invalid password provided' do
      let(:user) { create :user, login: 'jsmith', password: 'invalid'}
      subject { post :create, params: params}
      before { user }
      it_behaves_like 'unauthorized_standard_requests'
    end

    context 'when valid data provided' do
      let(:user) { create :user, login: 'jsmith', password: 'password'}
      subject { post :create, params: params}
      before { user }

      it 'should return 201 status code'  do
        subject
        expect(response).to have_http_status :created
      end

      # it 'should return proper json' do
      #   expect(json_data['attributes']).to eq({'token' => user.access_token.token})
      # end
    end

    context 'when invalid code provided' do
      let(:github_error) {
        double("Sawyer::Resource", error: "bad_verification_code")
      }

      before do
        allow_any_instance_of(Octokit::Client).to receive(
          :exchange_code_for_token).and_return(github_error)
      end
      subject {post :create, params: {code: "invalid_code"}}
      it_behaves_like "unauthorized_requests"
    end

    context 'when request is valid' do
      subject {post :create, params: {code: 'valid_code'}}

      let(:user_data) do
        {
            login: 'jconnor1',
            url: 'http://example.com',
            avatar_url: 'http://example.com/avatar',
            name: 'Jonh Connor'
        }
      end

      before do
        allow_any_instance_of(Octokit::Client).to receive(
          :exchange_code_for_token).and_return('validaccesstoken')

        allow_any_instance_of(Octokit::Client).to receive(
          :user).and_return(user_data)
      end

      it 'should return 201 status code'  do
        subject
        expect(response).to have_http_status :created
      end

      it 'should return proper json' do
        expect{ subject }.to change{User.count}.by 1
        user = User.find_by(login: 'jconnor1')
        expect(json_data['attributes']).to eq({
          'token' => user.access_token.token})
      end
    end
  end

  describe '#destroy' do
    subject { delete :destroy }

    context 'when authorization is empty' do
      it_should_behave_like 'forbidden_access'
    end

    context 'when authorization is invalid' do
      before { request.headers['authorization'] = 'Invalid token' }
      it_should_behave_like 'forbidden_access'
    end

    context 'when valid request' do
      let(:user) { create :user}
      let(:access_token) { user.create_access_token }

      before {
        request.headers['authorization'] = "Bearer #{access_token.token}"
      }

      it 'should return 204 status' do
        subject
        expect(response).to have_http_status(:no_content)
      end

      it 'should remove access token' do
        expect{ subject }.to change{AccessToken.count}.by -1
      end
    end
  end
end