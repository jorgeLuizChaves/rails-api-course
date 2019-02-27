require 'rails_helper'

describe UserAuthentication do

  context 'when login is by oauth' do

  end

  context 'when authentication is by user and password' do

  end

  describe '#perform' do
    let(:authenticator) { described_class.new('sample_code') }
    subject { authenticator.perform }

    context 'when code is incorrect' do
      let(:error) {
        double("Sawyer::Resource", error: "bad_verification_code")
      }

      before do
        allow_any_instance_of(Octokit::Client).to receive(
          :exchange_code_for_token).and_return(error)
      end

      it 'should return an error' do
        expect { subject}.to raise_error(UserAuthentication::UserAuthenticationError)
        expect(authenticator.user).to be_nil
      end
    end

    context 'when code is correct' do
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

      it 'should return an user' do
        expect { subject }.to change{ User.count }.by 1
      end

      it 'should reuse already registered user' do
        user = create :user, user_data
        expect { subject }.not_to change{ User.count }
        expect(authenticator.user).to eq(user)
      end

      it "should create and set user's access token" do
        expect{ subject }.to change{ AccessToken.count }.by 1
        expect(authenticator.access_token).to be_present
      end
    end
  end
end